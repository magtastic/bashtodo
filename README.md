# BashTodo

This is a super simple todo app. You can sort your tasks into projects and sort your task into three columns, _"TODO"_, _"DOING"_ and _"DONE"_. Every created tasks gets automatically assigned an id. Every command that changes a task requires a task ID.

## Commands

- [Init](#init)
- [New project](#new_project-_np_)
- [Switch project](#switch_projects-_sp_)
- [List projects](#projects-_p_)
- [Rename project](#change_current_project-_ccp_)
- [Delete project](#delete_project-_dp_)
- [Create task](#add)
- [Move task to todo](#todo)
- [Move task to doing](#doing)
- [Move task to done](#done)
- [List tasks](#ls)
- [Change task](#change)
- [Delete task](#delete-_del_)

### **init**

Initialize todos.
![init](./assets/init.gif)

### **new_project** _np_

_optional argument: <NEW_PROJECT_NAME>_

Creates a new project

![new_project](./assets/new_project.gif)

### **switch_projects** _sp_

_optional argument: <PROJECT_NAME>_

Switches focus to another project

![switch_projects](./assets/switch_projects.gif)

### **projects** _p_

Lists all projects

![projects](./assets/projects.gif)

### **change_current_project** _ccp_

_optional argument: <NEW_PROJECT_NAME>_

Renames the current project

![change_current_project](./assets/ccp.gif)

### **delete_project** _dp_

_optional argument: <PROJECT_NAME>_

Deletes a todo project

![delete_project](./assets/delete_project.gif)

### **add**

**argument: <TASK_DESCRIPTION>**

Adds a new task to Todo

![add](./assets/add.gif)

### **todo**

**argument: <TASK_ID>**

Moves a task to Todo

![todo](./assets/todo.gif)

### **doing**

**argument: <TASK_ID>**

Moves a task to Doing

![doing](./assets/doing.gif)

### **done**

**argument: <TASK_ID>**

Moves a task to Done

![done](./assets/done.gif)

### **ls**

Lists tasks in current project

![ls](./assets/ls.gif)

### **change**

**argument: <TASK_ID>**

Changes task

![change](./assets/change.gif)

### **delete** _del_

**argument: <TASK_ID>**

Deletes task

![delete](./assets/del.gif)
