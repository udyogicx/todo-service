type ToDo record {
  string text;
  boolean isDone;
};

type ToDoObject record {
  *ToDo;
  string id;
};
