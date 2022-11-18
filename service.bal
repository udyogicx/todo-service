import ballerina/http;
import ballerinax/mysql.driver as _;

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
}
