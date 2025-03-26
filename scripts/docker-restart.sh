#!/bin/bash

directories=($(docker container ls --filter label=com.docker.compose.project --format '{{.Label "com.docker.compose.project"}}' | sort | uniq | xargs -I {} echo "$HOME/config/{}"))

echo $directories > "$HOME/.last-docker-restart_$(date +%Y%m%d_%H%M%S).txt"

# Process each directory
# First bring down all containers
echo "Bringing down all containers..."
for dir in "${directories[@]}"; do
    echo "Bringing down containers in $dir..."

    # Change to directory
    cd "$dir" || {
        echo "Failed to change to directory $dir"
        continue
    }

    # Run docker compose down
    if docker compose down; then
        echo "Successfully brought down containers in $dir"
    else
        echo "Failed to bring down containers in $dir"
    fi

    # Return to parent directory
    cd $HOME

    echo "----------------------------------------"
done

# Then start up all containers
echo "Starting up all containers..."
for dir in "${directories[@]}"; do
    echo "Starting containers in $dir..."

    # Change to directory
    cd "$dir" || {
        echo "Failed to change to directory $dir"
        continue
    }

    # Run docker compose up
    if docker compose up -d; then
        echo "Successfully started containers in $dir"
    else
        echo "Failed to start containers in $dir"
    fi

    # Return to parent directory
    cd $HOME

    echo "----------------------------------------"
done

echo "All directories processed"

