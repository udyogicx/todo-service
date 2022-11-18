import ballerina/http;
import ballerinax/mysql.driver as _;
import ballerina/uuid;

ToDoObject[] todoList = [{id: "1", text: "This is a sampe todo", isDone: false}];

# A service representing a network-accessible API
# bound to port `9090`.
@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowCredentials: false,
        allowHeaders: ["accept", "Content-Type", "API-Key"],
        exposeHeaders: ["X-CUSTOM-HEADER"],
        maxAge: 84900
    }
}
service / on new http:Listener(9090) {
    # A resource to get todo list
    # + return - todo list which includes todo items
    resource function get todos() returns ToDoObject[] | error {
        return getTodos();
    }

    # A resource to add new todo item to todo list
    # + return - todo list which includes todo items
    resource function post todo(@http:Payload ToDo todoItem) returns ToDoObject[]|error {
        return addTodoItem(todoItem);
    }

    # A resource to get todo list
    # + return - todo list which includes todo items
    resource function get todosv1() returns ToDoObject[] {
        // Send a response back to the caller.
        return todoList;
    }

    resource function post todov1(@http:Payload ToDo todoItem) returns ToDoObject[] {
        todoList.push({id: uuid:createType1AsString(), text: todoItem.text, isDone: todoItem.isDone});
        return todoList;
    }
}
