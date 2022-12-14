import ballerina/http;
import ballerinax/mysql.driver as _;
import ballerina/log;
import ballerina/uuid;

ToDoObject[] todoList = [{id: "1", text: "This is a sampe todo", isDone: false, shared: false}];

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {
    # A resource to get todo list
    # + return - todo list which includes todo items
    resource function get todos/user/[string user]() returns ToDoObject[] | error {
        log:printInfo(string `User ${user} is accessing the function GET todos.`);
        return getTodos(user);
    }

    # A resource to add new todo item to todo list
    # + return - todo list which includes todo items
    resource function post todo/user/[string user](@http:Payload ToDo todoItem) returns ToDoObject[]|error {
        log:printInfo(string `User ${user} is accessing the function POST todo.`);
        return addTodoItem(todoItem, user);
    }

    # A resource to update an exisiting todo item in todo list
    # + return - todo list which includes todo items
    resource function put todo/user/[string user](@http:Payload ToDoObject todoItem) returns ToDoObject[]|error {
        log:printInfo(string `User ${user} is accessing the function PUT todo.`);
        return updateTodoItem(todoItem, user);
    }

    resource function get todos/shared/user/[string user](@http:Header {name: "X-JWT-Assertion"} string authHeader) returns ToDoObject[] | error {
        log:printInfo(string `X-JWT-Assertion: ${authHeader}`);
        boolean|error isAuthUser = checkAuthUser(user);
        if (isAuthUser == true) {
            log:printInfo(string `Authorized user ${user} is accessing the function GET todos/shared.`);
            return getSharedTodos();
        }
        return error("Unauthorized", message = string `User ${user} is not authorized.`, code = 401);
    }

    # A resource to get todo list
    # + return - todo list which includes todo items
    resource function get todosV3(@http:Header {name: "Authorization"} string authHeader) returns ToDoObject[] | error {
        string?|error user = getUser(authHeader);
        if (user is string) {
            log:printInfo(string `User ${user} is accessing the function GET todos.`);
            return getTodos(user);
        }
        return error("Cannot retrieve user, error: ", user);
    }

    # A resource to add new todo item to todo list
    # + return - todo list which includes todo items
    resource function post todoV3(@http:Payload ToDo todoItem, @http:Header {name: "Authorization"} string authHeader) returns ToDoObject[]|error {
        string?|error user = getUser(authHeader);
        if (user is string) {
            log:printInfo(string `User ${user} is accessing the function POST todo.`);
            return addTodoItem(todoItem, user);
        }
        return error("Cannot retrieve user, error: ", user);
    }

    # A resource to get todo list
    # + return - todo list which includes todo items
    resource function get todosv2() returns ToDoObject[] | error {
        return getTodosV2();
    }

    # A resource to add new todo item to todo list
    # + return - todo list which includes todo items
    resource function post todov2(@http:Payload ToDo todoItem) returns ToDoObject[]|error {
        return addTodoItemV2(todoItem);
    }

    # A resource to get todo list
    # + return - todo list which includes todo items
    resource function get todosv1() returns ToDoObject[] {
        // Send a response back to the caller.
        return todoList;
    }

    resource function post todov1(@http:Payload ToDo todoItem) returns ToDoObject[] {
        todoList.push({id: uuid:createType1AsString(), text: todoItem.text, isDone: todoItem.isDone, shared: todoItem.shared});
        return todoList;
    }
}
