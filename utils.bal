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
  host="db4free.net",
  user="id19870987_admin",
  password="*D#{5H!@)JV#AdY0", 
  database="id19870987_todo"
);

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
