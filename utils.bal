import ballerinax/mysql;
import ballerina/sql;
import ballerina/uuid;
import ballerina/jwt;

type ToDo record {
  string text;
  boolean isDone;
};

type ToDoObject record {
  *ToDo;
  string id;
};

configurable string dbHost = ?;
configurable string dbUser = ?;
configurable string dbPassword = ?;
configurable string database = ?;

configurable string authIssuer = ?;
configurable string[] authAudience = ?;

function getUser(string authHeader) returns string?|error {
  [jwt:Header, jwt:Payload] [_, payload] = check jwt:decode(authHeader);
  return payload.sub;
}

function validateUser(string authHeader) returns string?|error {
  jwt:ValidatorConfig validatorConfig = {
    issuer: authIssuer,
    audience: authAudience,
    clockSkew: 60
  };
  jwt:Payload payload = check jwt:validate(authHeader, validatorConfig);
  return payload.sub;
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
    host="sql.freedb.tech",
    user="freedb_id19870987_admin",
    password="fgVtMvk6*mE8HjB", 
    database="freedb_id19870987_todo",
    connectionPool = { maxOpenConnections: 5 }
  );
  sql:ExecutionResult result = check dbClient->execute(`
    INSERT INTO todoitems (id, text, isDone, user)
    VALUES (${uuid:createType1AsString()}, ${todoItem.text}, ${todoItem.isDone}, ${userId})
  `);
  int|string? affectedRowCount = result.affectedRowCount;
  check dbClient.close();
  if affectedRowCount == 1 {
    return getTodos(userId);
  } else {
    return error("Unable to obtain last insert ID");
  }
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
