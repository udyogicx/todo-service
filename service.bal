import ballerina/http;
import ballerina/uuid;

type ToDo record {
    string text;
    boolean isDone;
};

type ToDoObject record {
    *ToDo;
    string id;
};

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

    # A resource to add new todo item to todo list
    # + return - todo list which includes todo items
    resource function post todo(@http:Payload ToDo todoItem) returns ToDoObject[] {
        todoList.push({id: uuid:createType1AsString(), text: todoItem.text, isDone: todoItem.isDone});
        return todoList;
    }
}
