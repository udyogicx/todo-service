import ballerina/http;
import ballerinax/mysql.driver as _;
import ballerina/uuid;

ToDoObject[] todoList = [{id: "1", text: "This is a sampe todo", isDone: false}];

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {
    # A resource to get todo list
    # + return - todo list which includes todo items
    resource function get todos() returns ToDoObject[] {
        // Send a response back to the caller.
        return todoList;
    }

    resource function post todo(@http:Payload ToDo todoItem) returns ToDoObject[] {
        todoList.push({id: uuid:createType1AsString(), text: todoItem.text, isDone: todoItem.isDone});
        return todoList;
    }
}
