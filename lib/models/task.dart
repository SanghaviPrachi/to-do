class Task {
  String id;
  String name;
  bool isCompleted;

  Task(this.name, {this.isCompleted = false, this.id = ''});

  void setName(String newName) {
    name = newName;
  }
}
