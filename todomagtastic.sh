#!/bin/bash

# GLOBAL VARS
PROGRAM_NAME=$(basename $0)
RC_FILE_LOCATION=~/.todomagrc
VALID_CONFIG_VARS=("TODOMAG_PATH", "CURRENT_PROJECT")
TODO_FOLDER_NAME="todo"
DOING_FOLDER_NAME="doing"
DONE_FOLDER_NAME="done"

NONE='\033[00m'
#COLORS
RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
PURPLE='\033[01;35m'
CYAN='\033[01;36m'
WHITE='\033[01;37m'

#STYLES
BOLD='\033[1m'
UNDERLINE='\033[4m'


# HELPER FUNCTIONS
getProjectName(){
  read -e projectName
  echo "CURRENT_PROJECT=$projectName"
  return
}

getUserPath(){
  read -e userPath
  echo "TODO_BASE_PATH=$userPath"
  return
}

getCurrentProjectPath() {
  source $RC_FILE_LOCATION
  echo "$TODO_BASE_PATH/$CURRENT_PROJECT"
  return
}


# COMMANDS
command_tst() {
  echo -e "${RED}Test red${NONE} more text no color but this is ${BOLD}bold${NONE} and this is ${UNDERLINE}underline.${NONE}"
}

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

command_init(){
  source $RC_FILE_LOCATION 2> /dev/null

  if [ -f $RC_FILE_LOCATION ]; then

    if [ -z "$TODO_BASE_PATH" ]
    then
      echo "Where would you like to store todos?"
      todoPathVariable="$(getUserPath)"
      echo $todoPathVariable >> $RC_FILE_LOCATION
    fi

    if [ -z "$CURRENT_PROJECT" ]
    then
      echo "Please input project name"
      currentProjectNameVariable="$(getProjectName)"
      echo $currentProjectNameVariable >> $RC_FILE_LOCATION
    fi

  else
    echo "Config file does not exist."
    echo "Creating config file at location $RC_FILE_LOCATION"
    touch $RC_FILE_LOCATION
    echo "Where would you like to store todos?"
    todoPathVariable="$(getUserPath)"
    echo "Please input project name"
    currentProjectNameVariable="$(getProjectName)"
    echo $todoPathVariable >> $RC_FILE_LOCATION
    echo $currentProjectNameVariable >> $RC_FILE_LOCATION
  fi

  source $RC_FILE_LOCATION
  mkdir -p $TODO_BASE_PATH
  mkdir -p "$TODO_BASE_PATH/$CURRENT_PROJECT"
  mkdir -p "$TODO_BASE_PATH/$CURRENT_PROJECT/$TODO_FOLDER_NAME"
  mkdir -p "$TODO_BASE_PATH/$CURRENT_PROJECT/$DOING_FOLDER_NAME"
  mkdir -p "$TODO_BASE_PATH/$CURRENT_PROJECT/$DONE_FOLDER_NAME"

  echo "${BOLD}Setup complete!${NONE}"
}

command_add(){
  source $RC_FILE_LOCATION
  id=$(echo $RANDOM | tr '[0-9]' '[a-z]')
  task=$@

  projectPath="$(getCurrentProjectPath)"
  currentTodoPath="$projectPath/$TODO_FOLDER_NAME"
  echo "TIMESTAMP=$(date)" >> "$currentTodoPath/$id.txt"
  echo "ID=$id" >> "$currentTodoPath/$id.txt"
  echo "TASK=$task" >> "$currentTodoPath/$id.txt"
  echo -e "${GREEN}Task created. (id: $id)${NONE}"
}

command_del(){
  command_delete $@
}

command_change(){
  source $RC_FILE_LOCATION
  task_id=$@

  projectPath="$(getCurrentProjectPath)"
  currentTodoPath="$projectPath/$TODO_FOLDER_NAME"
  currentDoingPath="$projectPath/$DOING_FOLDER_NAME"
  currentDonePath="$projectPath/$DONE_FOLDER_NAME"

  if [ -f "$currentTodoPath/$task_id.txt" ]; then
    echo "Task: $(sed -n -e '/^TASK=/p' "$currentTodoPath/$task_id.txt" | sed 's/^TASK=//') (TODO)"
    echo "Please enter new Task Message:"
    read -e newTask
    echo "$(sed '/^TASK=/ d' "$currentTodoPath/$task_id.txt")" > "$currentTodoPath/$task_id.txt"
    echo "TASK=$newTask" >> "$currentTodoPath/$task_id.txt"

    echo -e "${GREEN}Task is changed.${NONE}"
    echo "Task: $(sed -n -e '/^TASK=/p' "$currentTodoPath/$task_id.txt" | sed 's/^TASK=//') (TODO)"
    return
  fi

  if [ -f "$currentDoingPath/$task_id.txt" ]; then
    echo "Task: $(sed -n -e '/^TASK=/p' "$currentDoingPath/$task_id.txt" | sed 's/^TASK=//') (DOING)"
    echo "Please enter new Task Message:"
    read -e newTask
    echo "$(sed '/^TASK=/ d' "$currentDoingPath/$task_id.txt")" > "$currentDoingPath/$task_id.txt"
    echo "TASK=$newTask" >> "$currentDoingPath/$task_id.txt"

    echo -e "${GREEN}Task is changed.${NONE}"
    echo "Task: $(sed -n -e '/^TASK=/p' "$currentDoingPath/$task_id.txt" | sed 's/^TASK=//') (DOING)"
    return
  fi

  if [ -f "$currentDonePath/$task_id.txt" ]; then
    echo "Task: $(sed -n -e '/^TASK=/p' "$currentDonePath/$task_id.txt" | sed 's/^TASK=//') (DONE)"
    echo "Please enter new Task Message:"
    read -e newTask
    echo "$(sed '/^TASK=/ d' "$currentDonePath/$task_id.txt")" > "$currentDonePath/$task_id.txt"
    echo "TASK=$newTask" >> "$currentDonePath/$task_id.txt"

    echo -e "${GREEN}Task is changed.${NONE}"
    echo "Task: $(sed -n -e '/^TASK=/p' "$currentDonePath/$task_id.txt" | sed 's/^TASK=//') (DONE)"
    return
  fi
}

command_doing(){
  source $RC_FILE_LOCATION
  task_id=$@

  projectPath="$(getCurrentProjectPath)"
  currentTodoPath="$projectPath/$TODO_FOLDER_NAME"
  currentDoingPath="$projectPath/$DOING_FOLDER_NAME"
  currentDonePath="$projectPath/$DONE_FOLDER_NAME"

  if [ -f "$currentTodoPath/$task_id.txt" ]; then
    mv "$currentTodoPath/$task_id.txt" "$currentDoingPath/$task_id.txt"
    echo -e "${GREEN}TaskId: $task_id was moved from TODO to DOING${NONE}"
    return
  fi

  if [ -f "$currentDonePath/$task_id.txt" ]; then
    mv "$currentDonePath/$task_id.txt" "$currentDoingPath/$task_id.txt"
    echo -e "${GREEN}TaskId: $task_id was moved from DONE to DOING${NONE}"
    return
  fi

  if [ -f "$currentDoingPath/$task_id.txt" ]; then
    echo -e "${YELLOW}TaskId: $task_id is already in DOING${NONE}"
    return
  fi

  echo -e "${RED}Did not find task with id: $task_id${NONE}"
}

command_done(){
  source $RC_FILE_LOCATION
  task_id=$@

  projectPath="$(getCurrentProjectPath)"
  currentTodoPath="$projectPath/$TODO_FOLDER_NAME"
  currentDoingPath="$projectPath/$DOING_FOLDER_NAME"
  currentDonePath="$projectPath/$DONE_FOLDER_NAME"

  if [ -f "$currentTodoPath/$task_id.txt" ]; then
    mv "$currentTodoPath/$task_id.txt" "$currentDonePath/$task_id.txt"
    echo -e "${GREEN}TaskId: $task_id was moved from TODO to DONE${NONE}"
    return
  fi

  if [ -f "$currentDoingPath/$task_id.txt" ]; then
    mv "$currentDoingPath/$task_id.txt" "$currentDonePath/$task_id.txt"
    echo -e "${GREEN}TaskId: $task_id was moved from DOING to DONE${NONE}"
    return
  fi

  if [ -f "$currentDonePath/$task_id.txt" ]; then
    echo -e "${YELLOW}TaskId: $task_id is already in DONE${NONE}"
    return
  fi

  echo -e "${RED}Did not find task with id: $task_id${NONE}"
}

command_todo(){
  source $RC_FILE_LOCATION
  task_id=$@

  projectPath="$(getCurrentProjectPath)"
  currentTodoPath="$projectPath/$TODO_FOLDER_NAME"
  currentDoingPath="$projectPath/$DOING_FOLDER_NAME"
  currentDonePath="$projectPath/$DONE_FOLDER_NAME"

  if [ -f "$currentDoingPath/$task_id.txt" ]; then
    mv "$currentDoingPath/$task_id.txt" "$currentTodoPath/$task_id.txt"
    echo -e "${GREEN}TaskId: $task_id was moved from DOING to TODO${NONE}"
    return
  fi

  if [ -f "$currentDonePath/$task_id.txt" ]; then
    mv "$currentDonePath/$task_id.txt" "$currentTodoPath/$task_id.txt"
    echo -e "${GREEN}TaskId: $task_id was moved from DONE to TODO${NONE}"
    return
  fi

  if [ -f "$currentTodoPath/$task_id.txt" ]; then
    echo -e "${YELLOW}TaskId: $task_id is already in TODO${NONE}"
    return
  fi

  echo -e "${{RED}Did not find task with id: $task_id${NONE}"
}

command_delete(){
  source $RC_FILE_LOCATION
  task_id=$@

  projectPath="$(getCurrentProjectPath)"
  currentTodoPath="$projectPath/$TODO_FOLDER_NAME"
  currentDoingPath="$projectPath/$DOING_FOLDER_NAME"
  currentDonePath="$projectPath/$DONE_FOLDER_NAME"

  if [ -f "$currentTodoPath/$task_id.txt" ]; then
    rm  -f "$currentTodoPath/$task_id.txt"
    echo -e "${GREEN}Task deleted.${NONE}"
    return
  fi

  if [ -f "$currentDoingPath/$task_id.txt" ]; then
    rm  -f "$currentDoingPath/$task_id.txt"
    echo -e "${GREEN}Task deleted.${NONE}"
    return
  fi

  if [ -f "$currentDonePath/$task_id.txt" ]; then
    rm  -f "$currentDonePath/$task_id.txt"
    echo -e "${GREEN}Task deleted.${NONE}"
    return
  fi

  echo -e "${RED}Task not found.${NONE}"
}

command_sp() {
  command_switch_projects $@
}

command_switch_projects() {
  source $RC_FILE_LOCATION
  project_name=$@

  if [ -z "$project_name" ]
  then
    echo "Please insert a project name..."
    read project_name
  fi

  if [ $project_name = $CURRENT_PROJECT ]
  then
    echo -e "${YELLOW}$project_name is already active${NONE}"
    return
  fi

  newProjectPath="$TODO_BASE_PATH/$project_name"

  if [ -d $newProjectPath ]
  then
    echo "$(sed '/^CURRENT_PROJECT=/ d' $RC_FILE_LOCATION)" > $RC_FILE_LOCATION
    echo "CURRENT_PROJECT=$project_name" >> $RC_FILE_LOCATION
    echo -e "${GREEN}${newProjectPath#${TODO_BASE_PATH}/} is now active${NONE}"
  else
    echo -e "${RED}Could not find project: $project_name${NONE}"
    echo "Use the projects (p) command to list all projects"
  fi
}

command_ccp(){
  command_change_current_project $@
}

command_change_current_project(){
  source $RC_FILE_LOCATION
  project_name=$@

  if [ -z "$project_name" ]
  then
    echo "Please insert a project name..."
    read project_name
  fi


  [[ $project_name = *[[:space:]]* ]]  && echo -e "${RED}Cannot name project with whitespaces${NONE}" && return

  mv "$TODO_BASE_PATH/$CURRENT_PROJECT" "$TODO_BASE_PATH/$project_name"
  echo "$(sed '/^CURRENT_PROJECT=/ d' $RC_FILE_LOCATION)" > $RC_FILE_LOCATION
  echo "CURRENT_PROJECT=$project_name" >> $RC_FILE_LOCATION
  echo -e "${GREEN}Project changed from $CURRENT_PROJECT to $project_name${NONE}"
}

command_dp(){
  command_delete_project $@
}

command_delete_project(){
  source $RC_FILE_LOCATION
  project_name=$@

  if [ -z "$project_name" ]
  then
    echo "Please insert a project name..."
    read project_name
  fi

  if [ $project_name = $CURRENT_PROJECT ]
  then
    echo -e "${RED}Sorry. Cannot delete active projects.${NONE}"
    echo "Please switch projects (sp) and try again."
    return
  fi

  projectPath="$TODO_BASE_PATH/$project_name"

  if [ -d $projectPath ]
  then
    num_of_todos=$(ls -1 "$projectPath/$TODO_FOLDER_NAME" | wc -l | tr -d '[:space:]')
    num_of_doings=$(ls -1 "$projectPath/$DOING_FOLDER_NAME" | wc -l | tr -d '[:space:]')
    num_of_dones=$(ls -1 "$projectPath/$DONE_FOLDER_NAME" | wc -l | tr -d '[:space:]')
    total_num_of_tasks=$(($num_of_dones + $num_of_todos + $num_of_doings))

    if [ "$total_num_of_tasks" -gt "0" ]; then
      echo "$project_name has $total_num_of_tasks. Are you sure you want to delete the project?"
      while true; do
        read -p "Do you wish to install this program? (y/n)" yn
          case $yn in
            [Yy]* ) break;;
            [Nn]* ) echo "Canceled."; exit;;
            * ) echo -e "${BOLD}Please answer yes or no.${NONE}";;
          esac
      done
    fi

    rm -rf "$TODO_BASE_PATH/$project_name"
    echo -e "${GREEN}Project deleted.${NONE}"
  else
    echo -e "${RED}Could not find project: $project_name${NONE}"
    echo "Use the projects (p) command to list all projects"
  fi
}


command_np(){
  command_new_project $@
}

command_new_project() {
  source $RC_FILE_LOCATION
  project_name=$@

  if [ -z "$project_name" ]
  then
    echo "Please insert a project name..."
    read project_name
  fi

  [[ $project_name = *[[:space:]]* ]]  && echo -e "${RED}Cannot name project with whitespaces${NONE}" && return

  newProjectPath="$TODO_BASE_PATH/$project_name"

  if [ -d "$newProjectPath" ]
  then
    echo -e "${YELLOW}You already have a project named: $project_name.${NONE}"
    return
  fi


  mkdir -p "$newProjectPath"
  mkdir -p "$newProjectPath/$TODO_FOLDER_NAME"
  mkdir -p "$newProjectPath/$DOING_FOLDER_NAME"
  mkdir -p "$newProjectPath/$DONE_FOLDER_NAME"

  echo -e "${GREEN}New project created: $project_name${NONE}"
  command_sp $project_name
}

command_p() {
  command_projects $@
}

command_projects() {
  source $RC_FILE_LOCATION
  num_of_projects=$(ls -1 "$TODO_BASE_PATH" | wc -l | tr -d '[:space:]')

  if [ "$num_of_projects" = "1" ]; then
    echo "You have $num_of_projects project."
  else
    echo "You have $num_of_projects projects."
  fi

  echo "Projects:"
  shopt -s nullglob
  for projectPath in $TODO_BASE_PATH/*; do
    if [ -d ${projectPath} ]; then
      # Removes the base path from project path.
      project_name="${projectPath#${TODO_BASE_PATH}/}"

      num_of_todos=$(ls -1 "$projectPath/$TODO_FOLDER_NAME" | wc -l | tr -d '[:space:]')
      num_of_doings=$(ls -1 "$projectPath/$DOING_FOLDER_NAME" | wc -l | tr -d '[:space:]')
      num_of_dones=$(ls -1 "$projectPath/$DONE_FOLDER_NAME" | wc -l | tr -d '[:space:]')

      if [ $project_name = $CURRENT_PROJECT ]
      then
        echo -e "${GREEN} $project_name ($(($num_of_dones + $num_of_todos + $num_of_doings)))${NONE}"
      else
        echo -e "${YELLOW} $project_name ($(($num_of_dones + $num_of_todos + $num_of_doings)))${NONE}"
      fi

    fi
  done
}

command_ls(){
  source $RC_FILE_LOCATION

  projectPath="$(getCurrentProjectPath)"
  currentTodoPath="$projectPath/$TODO_FOLDER_NAME"
  currentDoingPath="$projectPath/$DOING_FOLDER_NAME"
  currentDonePath="$projectPath/$DONE_FOLDER_NAME"

  num_of_todos=$(ls -1 "$currentTodoPath" | wc -l | tr -d '[:space:]')
  num_of_doings=$(ls -1 "$currentDoingPath" | wc -l | tr -d '[:space:]')
  num_of_dones=$(ls -1 "$currentDonePath" | wc -l | tr -d '[:space:]')

  echo -e "${BOLD}Current Project: $CURRENT_PROJECT${NONE}"
  echo "--------------------"
  echo -e "${RED}${UNDERLINE}TODO ($num_of_todos):${NONE}${RED}"
  shopt -s nullglob

  if [ "$num_of_todos" -gt "0" ]; then
    declare -a todoArray
    for file in "$currentTodoPath/*.txt"
    do
      todoArray=(${todoArray[*]} $file)
    done

    for item in "${todoArray[@]}"
    do
      echo "($(sed -n -e '/^ID=/p' $item | sed 's/^ID=//'))  $(sed -n -e '/^TASK=/p' $item | sed 's/^TASK=//') (created at: $(sed -n -e '/^TIMESTAMP=/p' $item | sed 's/^TIMESTAMP=//'))"
    done
  fi

  echo -e "${NONE}--------------------"
  echo -e "${YELLOW}${UNDERLINE}DOING ($num_of_doings):${NONE}${YELLOW}"

  if [ "$num_of_doings" -gt "0" ]; then
    declare -a doingArray
    for file in "$currentDoingPath/*.txt"
    do
      doingArray=(${doingArray[*]} $file)
    done

    for item in "${doingArray[@]}"
    do
      echo "($(sed -n -e '/^ID=/p' $item | sed 's/^ID=//'))  $(sed -n -e '/^TASK=/p' $item | sed 's/^TASK=//') (created at: $(sed -n -e '/^TIMESTAMP=/p' $item | sed 's/^TIMESTAMP=//'))"
    done
  fi

  echo -e "${NONE}--------------------"
  echo -e "${GREEN}${UNDERLINE}DONE ($num_of_dones):${NONE}${GREEN}"

  if [ "$num_of_dones" -gt "0" ]; then
    declare -a doneArray
    for file in "$currentDonePath/*.txt"
    do
      doneArray=(${doneArray[*]} $file)
    done

    for item in "${doneArray[@]}"
    do
      echo "($(sed -n -e '/^ID=/p' $item | sed 's/^ID=//'))  $(sed -n -e '/^TASK=/p' $item | sed 's/^TASK=//') (created at: $(sed -n -e '/^TIMESTAMP=/p' $item | sed 's/^TIMESTAMP=//'))"
    done
  fi

  echo -e "${NONE}--------------------"
  echo -e "${CYAN}${UNDERLINE}total ($(($num_of_dones + $num_of_todos + $num_of_doings)))${NONE}"
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
