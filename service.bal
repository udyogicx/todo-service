import ballerina/http;
import ballerinax/mysql.driver as _;
import ballerina/log;

ToDoObject[] todoList = [{id: "1", text: "This is a sampe todo", isDone: false}];

# A service representing a network-accessible API
# bound to port `9090`.
@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowCredentials: false,
        maxAge: 84900
    }
}
service / on new http:Listener(9090) {
    # A resource to get todo list
    # + return - todo list which includes todo items
    resource function get todos(@http:Header {name: "Authorization"} string authHeader) returns ToDoObject[] | error {
        string?|error user = getUser(authHeader);
        if (user is string) {
            log:printInfo(string `User ${user} is accessing the function GET todos.`);
            return getTodos(user);
        }
        return error("Cannot retrieve user");
    }

    # A resource to add new todo item to todo list
    # + return - todo list which includes todo items
    resource function post todo(@http:Payload ToDo todoItem, @http:Header {name: "Authorization"} string authHeader) returns ToDoObject[]|error {
        string?|error user = getUser(authHeader);
        if (user is string) {
            log:printInfo(string `User ${user} is accessing the function POST todo.`);
            return addTodoItem(todoItem, user);
        }
        return error("Cannot retrieve user");
    }
}
