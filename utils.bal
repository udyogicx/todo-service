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

mysql:Client dbClient = check new(
  host="sql.freedb.tech",
  user="freedb_id19870987_admin",
  password="fgVtMvk6*mE8HjB", 
  database="freedb_id19870987_todo",
  connectionPool = { maxOpenConnections: 5 }
);

function closeDBClient() returns error? {
  sql:Error? close = dbClient.close();
  if close is sql:Error {
    return error("Unable to close db client");
  }
}

function getTodos() returns ToDoObject[] | error {
  ToDoObject[] todoItems = [];
  stream<ToDoObject, sql:Error?> resultStream = dbClient->query(`SELECT * FROM todoitems`);
  check from ToDoObject todoObject in resultStream
  do {
    todoItems.push(todoObject);
  };
  check resultStream.close();
  // Send a response back to the caller.
  return todoItems;
}

function addTodoItem(ToDo todoItem) returns ToDoObject[]|error {
  sql:ExecutionResult result = check dbClient->execute(`
    INSERT INTO todoitems (id, text, isDone)
    VALUES (${uuid:createType1AsString()}, ${todoItem.text}, ${todoItem.isDone})
  `);
  int|string? affectedRowCount = result.affectedRowCount;
  if affectedRowCount == 1 {
    return getTodos();
  } else {
    return error("Unable to obtain last insert ID");
  }
}
