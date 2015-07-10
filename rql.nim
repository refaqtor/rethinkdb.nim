
## This module provides all high-level API for query and manipulate data 

import asyncdispatch
import strtabs
import strutils
import json

import ql2
import term
import datum
import connection


type      
  RqlQuery* = ref object of RootObj
    conn*: RethinkClient
    term*: Term

  RqlDatabase* = ref object of RqlQuery
    db*: string

  RqlTable* = ref object of RqlQuery
    rdb*: RqlDatabase
    table*: string
    
proc run*(r: RqlQuery): Future[JsonNode] {.async.} =
  ## Run a query on a connection, returning a `JsonNode` contains single JSON result or an JsonArray, depending on the query.
  if not r.conn.isConnected:    
    await r.conn.connect()
  await r.conn.startQuery(r.term)
  var response = await r.conn.readResponse()

  case response.kind
  of SUCCESS_ATOM:
    result = response.data[0]
  of WAIT_COMPLETE:
    discard
  of SUCCESS_PARTIAL, SUCCESS_SEQUENCE:
    result = newJArray()  
    result.add(response.data)
    while response.kind == SUCCESS_PARTIAL:
      await r.conn.continueQuery(response.token)
      response = await r.conn.readResponse()
      result.add(response.data)
  of CLIENT_ERROR:
    raise newException(RqlClientError, $response.data[0])
  of COMPILE_ERROR:
    raise newException(RqlCompileError, $response.data[0])
  of RUNTIME_ERROR:
    raise newException(RqlRuntimeError, $response.data[0])
  else:
    raise newException(RqlDriverError, "Unknow response type $#" % [$response.kind])

proc db*(r: RethinkClient, db: string): RqlDatabase =
  ## Reference a database.    
  new(result)
  result.conn = r
  result.term = newTerm(DB)
  result.term.args.add(@db)
  
proc dbCreate*(r: RethinkClient, table: string): RqlQuery =
  ## Create a table  
  new(result)
  result.conn = r
  result.term = newTerm(DB_CREATE)
  result.term.args.add(@table)

proc dbDrop*(r: RethinkClient, table: string): RqlQuery =
  ## Drop a database
  new(result)
  result.conn = r
  result.term = newTerm(DB_DROP)
  result.term.args.add(@table)

proc dbList*(r: RethinkClient): RqlQuery =
  ## List all database names in the system. The result is a list of strings.
  new(result)
  result.conn = r
  result.term = newTerm(DB_LIST)

proc table*(r: RethinkClient, table: string): RqlTable =
  new(result)
  result.conn = r
  result.term = newTerm(TABLE)
  result.term.args.add(@table)
  
proc table*(r: RqlDatabase, table: string): RqlTable =
  ## Select all documents in a table
  new(result)
  result.conn = r.conn
  result.term = newTerm(TABLE)
  result.term.args.add(r.term)
  result.term.args.add(@table)

proc get*[T: int|string](r: RqlTable, t: T): RqlQuery =
  ## Get a document by primary key
  new(result)
  result.conn = r.conn
  result.term = newTerm(GET)
  result.term.args.add(r.term)
  result.term.args.add(@t)

proc getAll*[T: int|string](r: RqlTable, args: openArray[T], index = ""): RqlTable =
  ## Get all documents where the given value matches the value of the requested index
  ##
  ## Example:
  ##
  ## .. code-block:: nim
  ##  # with primary index
  ##  r.table("posts").getAll([1, 1]).run()
  ##  # with secondary index
  ##  r.table("posts").getAll(["nim", "lang"], "tags").run()  
  new(result)
  result.conn = r.conn
  result.term = newTerm(GET_ALL)
  result.term.args.add(r.term)

  for x in args:
    result.term.args.add(@x)

  if index != "":
    result.term.options = &{"index": &index}
  
proc filter*(r: RqlTable, data: openArray[tuple[key: string, val: MutableDatum]]): RqlTable =
  ## Get all the documents for which the given predicate is true
  new(result)
  result.conn = r.conn
  result.term = newTerm(FILTER)
  result.term.args.add(r.term) 
  result.term.args.add(@data)
