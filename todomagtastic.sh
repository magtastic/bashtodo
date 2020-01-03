#!/bin/bash

PROGRAM_NAME=$(basename $0)
RC_FILE_LOCATION=~/.todomagrc
VALID_CONFIG_VARS=("TODOMAG_PATH")
TODO_FOLDER_NAME="todo"
DOING_FOLDER_NAME="doing"
DONE_FOLDER_NAME="done"

command_help_menu(){
  echo ""
  echo "Usage: $PROGRAM_NAME <command> [options]"
  echo ""
  echo "command:"
  echo "    init    Initialize todos"
  echo "    add     Adds a new task to Todo"
  echo "    todo    Moves a task to Todo"
  echo "    doing   Moves a task to Doing"
  echo "    done    Moves a task to Done"
  echo "    change  Changes task"
  echo "    delete  Deletes task"
  echo ""
}

getUserPath(){
  read -e userPath
  echo "TODO_BASE_PATH=$userPath"
  return
}

command_init(){
  source $RC_FILE_LOCATION

  if [ -f $RC_FILE_LOCATION ]; then
    if [ -z "$TODO_BASE_PATH" ]
    then
      echo "Where would you like to store todos?"
      todoPathVariable="$(getUserPath)"
      echo $todoPathVariable >> $RC_FILE_LOCATION
    fi
  else
    echo "Config file does not exist."
    echo "Creating config file at location $RC_FILE_LOCATION"
    touch $RC_FILE_LOCATION
    echo "Where would you like to store todos?"
    todoPathVariable="$(getUserPath)"
    echo $todoPathVariable >> $RC_FILE_LOCATION
  fi

  source $RC_FILE_LOCATION mkdir -p $TODO_BASE_PATH
  mkdir -p "$TODO_BASE_PATH/$TODO_FOLDER_NAME"
  mkdir -p "$TODO_BASE_PATH/$DOING_FOLDER_NAME"
  mkdir -p "$TODO_BASE_PATH/$DONE_FOLDER_NAME"

  echo "Setup complete!"
}

command_add(){
  source $RC_FILE_LOCATION
  id=$(echo $RANDOM | tr '[0-9]' '[a-z]')
  task=$@
  echo "TIMESTAMP=$(date)" >> "$TODO_BASE_PATH/$TODO_FOLDER_NAME/$id.txt"
  echo "ID=$id" >> "$TODO_BASE_PATH/$TODO_FOLDER_NAME/$id.txt"
  echo "TASK=$task" >> "$TODO_BASE_PATH/$TODO_FOLDER_NAME/$id.txt"
  echo "Task created. (id: $id)"
}

command_del(){
  command_delete $@
}

command_change(){
  source $RC_FILE_LOCATION
  task_id=$@

  if [ -f "$TODO_BASE_PATH/$TODO_FOLDER_NAME/$task_id.txt" ]; then
    echo "Task: $(sed -n -e '/^TASK=/p' "$TODO_BASE_PATH/$TODO_FOLDER_NAME/$task_id.txt" | sed 's/^TASK=//') (TODO)"
    echo "Please enter new Task Message:"
    read -e newTask
    echo "$(sed '/^TASK=/ d' "$TODO_BASE_PATH/$TODO_FOLDER_NAME/$task_id.txt")" > "$TODO_BASE_PATH/$TODO_FOLDER_NAME/$task_id.txt"
    echo "TASK=$newTask" >> "$TODO_BASE_PATH/$TODO_FOLDER_NAME/$task_id.txt"

    echo "Task is changed."
    echo "Task: $(sed -n -e '/^TASK=/p' "$TODO_BASE_PATH/$TODO_FOLDER_NAME/$task_id.txt" | sed 's/^TASK=//') (TODO)"
    return
  fi

  if [ -f "$TODO_BASE_PATH/$DOING_FOLDER_NAME/$task_id.txt" ]; then
    echo "Task: $(sed -n -e '/^TASK=/p' "$TODO_BASE_PATH/$DOING_FOLDER_NAME/$task_id.txt" | sed 's/^TASK=//') (DOING)"
    echo "Please enter new Task Message:"
    read -e newTask
    echo "$(sed '/^TASK=/ d' "$TODO_BASE_PATH/$DOING_FOLDER_NAME/$task_id.txt")" > "$TODO_BASE_PATH/$DOING_FOLDER_NAME/$task_id.txt"
    echo "TASK=$newTask" >> "$TODO_BASE_PATH/$DOING_FOLDER_NAME/$task_id.txt"

    echo "Task is changed."
    echo "Task: $(sed -n -e '/^TASK=/p' "$TODO_BASE_PATH/$DOING_FOLDER_NAME/$task_id.txt" | sed 's/^TASK=//') (DOING)"
    return
  fi

  if [ -f "$TODO_BASE_PATH/$DONE_FOLDER_NAME/$task_id.txt" ]; then
    echo "Task: $(sed -n -e '/^TASK=/p' "$TODO_BASE_PATH/$DONE_FOLDER_NAME/$task_id.txt" | sed 's/^TASK=//') (DONE)"
    echo "Please enter new Task Message:"
    read -e newTask
    echo "$(sed '/^TASK=/ d' "$TODO_BASE_PATH/$DONE_FOLDER_NAME/$task_id.txt")" > "$TODO_BASE_PATH/$DONE_FOLDER_NAME/$task_id.txt"
    echo "TASK=$newTask" >> "$TODO_BASE_PATH/$DONE_FOLDER_NAME/$task_id.txt"

    echo "Task is changed."
    echo "Task: $(sed -n -e '/^TASK=/p' "$TODO_BASE_PATH/$DONE_FOLDER_NAME/$task_id.txt" | sed 's/^TASK=//') (DONE)"
    return
  fi
}

command_doing(){
  source $RC_FILE_LOCATION
  task_id=$@

  if [ -f "$TODO_BASE_PATH/$TODO_FOLDER_NAME/$task_id.txt" ]; then
    mv "$TODO_BASE_PATH/$TODO_FOLDER_NAME/$task_id.txt" "$TODO_BASE_PATH/$DOING_FOLDER_NAME/$task_id.txt"
    echo "TaskId: $task_id was moved from TODO to DOING"
    return
  fi

  if [ -f "$TODO_BASE_PATH/$DONE_FOLDER_NAME/$task_id.txt" ]; then
    mv "$TODO_BASE_PATH/$DONE_FOLDER_NAME/$task_id.txt" "$TODO_BASE_PATH/$DOING_FOLDER_NAME/$task_id.txt"
    echo "TaskId: $task_id was moved from DONE to DOING"
    return
  fi

  if [ -f "$TODO_BASE_PATH/$DOING_FOLDER_NAME/$task_id.txt" ]; then
    echo "TaskId: $task_id is already in DOING"
    return
  fi

  echo "Did not find task with id: $task_id"
}

command_done(){
  source $RC_FILE_LOCATION
  task_id=$@

  if [ -f "$TODO_BASE_PATH/$TODO_FOLDER_NAME/$task_id.txt" ]; then
    mv "$TODO_BASE_PATH/$TODO_FOLDER_NAME/$task_id.txt" "$TODO_BASE_PATH/$DONE_FOLDER_NAME/$task_id.txt"
    echo "TaskId: $task_id was moved from TODO to DONE"
    return
  fi

  if [ -f "$TODO_BASE_PATH/$DOING_FOLDER_NAME/$task_id.txt" ]; then
    mv "$TODO_BASE_PATH/$DOING_FOLDER_NAME/$task_id.txt" "$TODO_BASE_PATH/$DONE_FOLDER_NAME/$task_id.txt"
    echo "TaskId: $task_id was moved from DOING to DONE"
    return
  fi

  if [ -f "$TODO_BASE_PATH/$DONE_FOLDER_NAME/$task_id.txt" ]; then
    echo "TaskId: $task_id is already in DONE"
    return
  fi

  echo "Did not find task with id: $task_id"
}

command_todo(){
  source $RC_FILE_LOCATION
  task_id=$@

  if [ -f "$TODO_BASE_PATH/$DOING_FOLDER_NAME/$task_id.txt" ]; then
    mv "$TODO_BASE_PATH/$DOING_FOLDER_NAME/$task_id.txt" "$TODO_BASE_PATH/$TODO_FOLDER_NAME/$task_id.txt"
    echo "TaskId: $task_id was moved from DOING to TODO"
    return
  fi

  if [ -f "$TODO_BASE_PATH/$DONE_FOLDER_NAME/$task_id.txt" ]; then
    mv "$TODO_BASE_PATH/$DONE_FOLDER_NAME/$task_id.txt" "$TODO_BASE_PATH/$TODO_FOLDER_NAME/$task_id.txt"
    echo "TaskId: $task_id was moved from DONE to TODO"
    return
  fi

  if [ -f "$TODO_BASE_PATH/$TODO_FOLDER_NAME/$task_id.txt" ]; then
    echo "TaskId: $task_id is already in TODO"
    return
  fi

  echo "Did not find task with id: $task_id"
}

command_delete(){
  source $RC_FILE_LOCATION
  task_id=$@

  if [ -f "$TODO_BASE_PATH/$TODO_FOLDER_NAME/$task_id.txt" ]; then
    rm  -f "$TODO_BASE_PATH/$TODO_FOLDER_NAME/$task_id.txt"
    echo "Task deleted."
    return
  fi

  if [ -f "$TODO_BASE_PATH/$DOING_FOLDER_NAME/$task_id.txt" ]; then
    rm  -f "$TODO_BASE_PATH/$DOING_FOLDER_NAME/$task_id.txt"
    echo "Task deleted."
    return
  fi

  if [ -f "$TODO_BASE_PATH/$DONE_FOLDER_NAME/$task_id.txt" ]; then
    rm  -f "$TODO_BASE_PATH/$DONE_FOLDER_NAME/$task_id.txt"
    echo "Task deleted."
    return
  fi

  echo "Task not found."
}

command_ls(){
  source $RC_FILE_LOCATION

  num_of_todos=$(ls -1 "$TODO_BASE_PATH/$TODO_FOLDER_NAME" | wc -l | tr -d '[:space:]')
  num_of_doings=$(ls -1 "$TODO_BASE_PATH/$DOING_FOLDER_NAME" | wc -l | tr -d '[:space:]')
  num_of_dones=$(ls -1 "$TODO_BASE_PATH/$DONE_FOLDER_NAME" | wc -l | tr -d '[:space:]')

  echo "TODO ($num_of_todos):"
  shopt -s nullglob

  if [ "$num_of_todos" -gt "0" ]; then
    declare -a todoArray
    for file in "$TODO_BASE_PATH/$TODO_FOLDER_NAME/*.txt"
    do
      todoArray=(${todoArray[*]} $file)
    done

    for item in "${todoArray[@]}"
    do
      echo "($(sed -n -e '/^ID=/p' $item | sed 's/^ID=//')) Task: $(sed -n -e '/^TASK=/p' $item | sed 's/^TASK=//') (created at: $(sed -n -e '/^TIMESTAMP=/p' $item | sed 's/^TIMESTAMP=//'))"
    done
  fi

  echo "--------------------"
  echo "DOING ($num_of_doings):"

  if [ "$num_of_doings" -gt "0" ]; then
    declare -a doingArray
    for file in "$TODO_BASE_PATH/$DOING_FOLDER_NAME/*.txt"
    do
      doingArray=(${doingArray[*]} $file)
    done

    for item in "${doingArray[@]}"
    do
      echo "($(sed -n -e '/^ID=/p' $item | sed 's/^ID=//')) Task: $(sed -n -e '/^TASK=/p' $item | sed 's/^TASK=//') (created at: $(sed -n -e '/^TIMESTAMP=/p' $item | sed 's/^TIMESTAMP=//'))"
    done
  fi

  echo "--------------------"
  echo "DONE ($num_of_dones):"

  if [ "$num_of_dones" -gt "0" ]; then
    declare -a doneArray
    for file in "$TODO_BASE_PATH/$DONE_FOLDER_NAME/*.txt"
    do
      doneArray=(${doneArray[*]} $file)
    done

    for item in "${doneArray[@]}"
    do
      echo "($(sed -n -e '/^ID=/p' $item | sed 's/^ID=//')) Task: $(sed -n -e '/^TASK=/p' $item | sed 's/^TASK=//') (created at: $(sed -n -e '/^TIMESTAMP=/p' $item | sed 's/^TIMESTAMP=//'))"
    done
  fi

  echo "--------------------"
  echo "total ($(($num_of_dones + $num_of_todos + $num_of_doings)))"
}

subcommand=$1
case $subcommand in
    "" | "-h" | "--help")
        command_help_menu
        ;;
    *)
        shift
        command_${subcommand} $@
        if [ $? = 127 ]; then
            echo "Error: '$subcommand' is not a known subcommand." >&2
            echo "       Run '$ProgName --help' for a list of known subcommands." >&2
            exit 1
        fi
        ;;
esac
