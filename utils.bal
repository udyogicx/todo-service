import ballerinax/mysql;
import ballerina/sql;
import ballerina/uuid;

type ToDo record {
  string text;
  boolean isDone;
};

type ToDoObject record {
  *ToDo;
  string id;
};

function getTodos() returns ToDoObject[] | error {
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

function addTodoItem(ToDo todoItem) returns ToDoObject[]|error {
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
    return getTodos();
  } else {
    return error("Unable to obtain last insert ID");
  }
}
