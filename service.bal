import ballerina/http;
import ballerinax/mysql.driver as _;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {
    # A resource to get todo list
    # + return - todo list which includes todo items
    resource function get todos() returns ToDoObject[] | error {
        ToDoObject[]|error todoList = getTodos();
        error? closeDBClientResult = closeDBClient();
        if closeDBClientResult is error {
            return closeDBClientResult;
        }
        return todoList;
    }

    # A resource to add new todo item to todo list
    # + return - todo list which includes todo items
    resource function post todo(@http:Payload ToDo todoItem) returns ToDoObject[]|error {
        ToDoObject[]|error todoList = addTodoItem(todoItem);
        error? closeDBClientResult = closeDBClient();
        if closeDBClientResult is error {
            return closeDBClientResult;
        }
        return todoList;
    }
}
