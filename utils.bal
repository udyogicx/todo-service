import ballerinax/mysql;
import ballerina/sql;
import ballerina/uuid;
import ballerina/jwt;
import ballerina/regex;

type ToDo record {
  string text;
  boolean isDone;
  boolean shared;
};

type ToDoObject record {
  *ToDo;
  string id;
};

type UserScopes record {
  string scopes;
};

configurable string dbHost = ?;
configurable string dbUser = ?;
configurable string dbPassword = ?;
configurable string database = ?;

function getUser(string authHeader) returns string?|error {
  [jwt:Header, jwt:Payload] [_, payload] = check jwt:decode(authHeader);
  return payload.sub;
}

function checkAuthUser(string userId) returns boolean | error {
  mysql:Client dbClient = check new(
    host=dbHost,
    user=dbUser,
    password=dbPassword, 
    database=database,
    connectionPool = { maxOpenConnections: 5 }
  );
  UserScopes userScopes = check dbClient->queryRow(
    `SELECT scopes FROM userscopes WHERE user = ${userId}`
  );
  string[] scopes = regex:split(userScopes.scopes, ",");
  check dbClient.close();
  return scopes.indexOf("user") != () || scopes.indexOf("admin") != ();
  // return scopes;
  // return ["admin", "user"];
}

function getTodos(string userId) returns ToDoObject[] | error {
  mysql:Client dbClient = check new(
    host=dbHost,
    user=dbUser,
    password=dbPassword, 
    database=database,
    connectionPool = { maxOpenConnections: 5 }
  );
  ToDoObject[] todoItems = [];
  stream<ToDoObject, sql:Error?> resultStream = dbClient->query(
    `SELECT * FROM todoitems WHERE user = ${userId}`
  );
  check from ToDoObject todoObject in resultStream
  do {
    todoItems.push(todoObject);
  };
  check resultStream.close();
  check dbClient.close();
  // Send a response back to the caller.
  return todoItems;
}

function addTodoItem(ToDo todoItem, string userId) returns ToDoObject[]|error {
  mysql:Client dbClient = check new(
    host=dbHost,
    user=dbUser,
    password=dbPassword, 
    database=database,
    connectionPool = { maxOpenConnections: 5 }
  );
  sql:ExecutionResult result = check dbClient->execute(`
    INSERT INTO todoitems (id, text, isDone, user, shared)
    VALUES (${uuid:createType1AsString()}, ${todoItem.text}, ${todoItem.isDone}, ${userId}, ${todoItem.shared})
  `);
  int|string? affectedRowCount = result.affectedRowCount;
  check dbClient.close();
  if affectedRowCount == 1 {
    return getTodos(userId);
  } else {
    return error("Unable to obtain last insert ID");
  }
}

function updateTodoItem(ToDoObject todoItem, string userId) returns ToDoObject[]|error {
  mysql:Client dbClient = check new(
    host=dbHost,
    user=dbUser,
    password=dbPassword, 
    database=database,
    connectionPool = { maxOpenConnections: 5 }
  );
  sql:ExecutionResult result = check dbClient->execute(`
    UPDATE todoitems SET
      text = ${todoItem.text}, 
      isDone = ${todoItem.isDone},
      shared = ${todoItem.shared}
    WHERE id = ${todoItem.id} AND user = ${userId}
  `);
  int|string? affectedRowCount = result.affectedRowCount;
  check dbClient.close();
  if affectedRowCount == 1 {
    return getTodos(userId);
  } else {
    return error("Unable to obtain last insert ID");
  }
}

function getSharedTodos() returns ToDoObject[] | error {
  mysql:Client dbClient = check new(
    host=dbHost,
    user=dbUser,
    password=dbPassword, 
    database=database,
    connectionPool = { maxOpenConnections: 5 }
  );
  ToDoObject[] todoItems = [];
  stream<ToDoObject, sql:Error?> resultStream = dbClient->query(
    `SELECT * FROM todoitems WHERE shared = true`
  );
  check from ToDoObject todoObject in resultStream
  do {
    todoItems.push(todoObject);
  };
  check resultStream.close();
  check dbClient.close();
  // Send a response back to the caller.
  return todoItems;
}

function getTodosV2() returns ToDoObject[] | error {
  mysql:Client dbClient = check new(
    host="sql.freedb.tech",
    user="freedb_id19870987_admin",
    password="fgVtMvk6*mE8HjB", 
    database="freedb_id19870987_todo",
    connectionPool = { maxOpenConnections: 5 }
  );
  ToDoObject[] todoItems = [];
  stream<ToDoObject, sql:Error?> resultStream = dbClient->query(`SELECT * FROM todoitems`);
  check from ToDoObject todoObject in resultStream
  do {
    todoItems.push(todoObject);
  };
  check resultStream.close();
  check dbClient.close();
  // Send a response back to the caller.
  return todoItems;
}

function addTodoItemV2(ToDo todoItem) returns ToDoObject[]|error {
  mysql:Client dbClient = check new(
    host="sql.freedb.tech",
    user="freedb_id19870987_admin",
    password="fgVtMvk6*mE8HjB", 
    database="freedb_id19870987_todo",
    connectionPool = { maxOpenConnections: 5 }
  );
  sql:ExecutionResult result = check dbClient->execute(`
    INSERT INTO todoitems (id, text, isDone)
    VALUES (${uuid:createType1AsString()}, ${todoItem.text}, ${todoItem.isDone})
  `);
  int|string? affectedRowCount = result.affectedRowCount;
  check dbClient.close();
  if affectedRowCount == 1 {
    return getTodosV2();
  } else {
    return error("Unable to obtain last insert ID");
  }
}
