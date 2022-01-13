// DGRfinalProject.cpp : 이 파일에는 'main' 함수가 포함됩니다. 거기서 프로그램 실행이 시작되고 종료됩니다.
//
#define _CRT_SECURE_NO_WARNINGS
#include <iostream>
#include<stdbool.h>
#define maze_maxsize 10
#define buffersize 150

struct node {
    int self_x;
    int self_y;
    int parent_x;
    int parent_y;
    int f;
    int g;
    int h;
};





int append(struct node* list[buffersize], struct node* add, int size) {
    list[size] = add;
    return(size + 1);
}

int find(struct node* list[buffersize], struct node* findnode, int size) {
    int check = -1;
    int i;
    for (i = 0; i < size; i++) {
        if (list[i]->self_x == findnode->self_x && list[i]->self_y == findnode->self_y) {
            check = i; break;
        }
    }
    return check;
}

int rem(struct node* list[buffersize], int index, int size) {
    int i;
    for (i = index; i < size; i++) {
        list[i] = list[i + 1];
    }
    return(size - 1);
}

int findH(struct node* checknode, int desig_x, int desig_y) {
    int present_x = checknode->self_x;
    int present_y = checknode->self_y;
    int x = abs(desig_x - present_x);
    int y = abs(desig_y - present_y);
    int distance = pow(x,2) + pow(y,2);
    distance = 10*sqrt(distance);
    return (int)distance;
}

bool boundarycheck(struct node* checknode, int h, int w) {
    bool check = true;
    int check_x = checknode->self_x;
    int check_y = checknode->self_y;
    if (check_x < 0 ) check = false;
    if (check_y < 0 ) check = false;
    if (check_x > w ) check = false;
    if (check_y > h ) check = false;
    return check;
}

bool obstaclecheck(struct node* checknode, bool maze[][maze_maxsize]) {
    bool check = true;
    int check_x = checknode->self_x;
    int check_y = checknode->self_y;
    if (maze[check_y][check_x] == false) check = false;
    return check;
}

bool findF(struct node* checknode, int h, int w, int desig_x, int desig_y, bool maze[][maze_maxsize]) {
    if (boundarycheck(checknode, h, w) == true) {
        if (obstaclecheck(checknode, maze) == true) {
            checknode->h = findH(checknode, desig_x, desig_y);
            checknode->g = checknode->g + 10;
            checknode->f = checknode->h + checknode->g;
            return true;
        }
        else return false;
    }
    else return false;
}

void printmaze(bool maze[][maze_maxsize], int h, int w) {
    printf("Input\n");
    printf("%d, %d\n", h, w);
    int i;
    int j;
    for (i = 0; i < h; i++) {
        for (j = 0; j < w; j++) {
            if (maze[i][j] == true) printf("0 ");
            else printf("1 ");
        }
        printf("\n");
    }
}
void printpath(struct node* path[buffersize], int size, int start_x, int start_y, int desig_x, int desig_y) {
    printf("\nOutput\n");
    int i;
    if (path[0]->self_x == desig_x && path[0]->self_y == desig_y) {
        for (i = size - 1; i > -1; i--) {
            printf("( %d , %d )\n", path[i]->self_y, path[i]->self_x);
        }
    }
    else {
        printf("0\n");
    }
}






//h-1, w-1
int findpath(int start_x, int start_y, int desig_x, int desig_y, int h, int w, bool maze[][maze_maxsize], struct node* path[buffersize], int path_size) {
    struct node nodemap[maze_maxsize][maze_maxsize];
    int i;
    int j;
    for (i = 0; i < maze_maxsize; i++) {
        for (j = 0; j < maze_maxsize; j++) {
            nodemap[i][j].self_x = i;
            nodemap[i][j].self_y = j;
            nodemap[i][j].parent_x = -1;
            nodemap[i][j].parent_y = -1;
            nodemap[i][j].f = 0;
            nodemap[i][j].g = 0;
            nodemap[i][j].h = 0;
        }
    } //initialize
    struct node* currentnode = &nodemap[start_x][start_y];
    struct node* openset[buffersize];
    openset[0] = currentnode;
    int openset_size = 1;
    
    struct node* closedset[buffersize];
    int closedset_size = 0;


    int current_x;
    int current_y;
    struct node* surroundNode[4];
    int surroundNode_size = 0;
    struct node* var;

    while (openset_size > 0) {
        currentnode = openset[0];
        for (i = 0; i < openset_size; i++) {
            if (currentnode->f > openset[i]->f) currentnode = openset[i];
        }
        
        if (currentnode->self_x == desig_x && currentnode->self_y == desig_y) break;

        closedset_size = append(closedset, currentnode, closedset_size);
        openset_size = rem(openset, find(openset, currentnode, openset_size), openset_size);

        current_x = currentnode->self_x;
        current_y = currentnode->self_y;
        //printf("%d %d\n", current_x, current_y);
        surroundNode_size = 0;
        if (current_x < w) surroundNode_size = append(surroundNode, &nodemap[current_x + 1][current_y], surroundNode_size);
        if (current_x > 0) surroundNode_size = append(surroundNode, &nodemap[current_x - 1][current_y], surroundNode_size);
        if (current_y < h) surroundNode_size = append(surroundNode, &nodemap[current_x][current_y + 1], surroundNode_size);
        if (current_y > 0) surroundNode_size = append(surroundNode, &nodemap[current_x][current_y - 1], surroundNode_size);



        
        for (j=0; j<surroundNode_size; j++){
            var = surroundNode[j];
            if (findF(var, h, w, desig_x, desig_y, maze) == true) { 
                if (find(closedset, surroundNode[j], closedset_size) == -1) {
                    if (find(openset, surroundNode[j], openset_size) == -1) {
                        var->parent_x = current_x;
                        var->parent_y = current_y;
                        openset_size = append(openset, var, openset_size);
                        nodemap[var->self_x][var->self_y] = *var;
                    }
                    else {
                        if (currentnode->g + 10 < var->g) {
                            var->parent_x = current_x;
                            var->parent_y = current_y;
                            var->g = currentnode->g + 10;
                            var->f = var->g + var->h;

                            //openset_size = rem(openset, find(openset, currentnode, openset_size), openset_size);
                            openset_size = append(openset, var, openset_size);
                            nodemap[var->self_x][var->self_y] = *var;
                        }
                    }
                }
            }
        }
    }
    struct node* countnode = currentnode;
    path_size = append(path, countnode, path_size);
    while (!(countnode->self_x == start_x && countnode->self_y == start_y)) {
        countnode = &nodemap[countnode->parent_x][countnode->parent_y];
        path_size = append(path, countnode, path_size);
    }
    return path_size;
}


int main()
{
    int h = 0;
    int w = 0;
    
    int i = 0;
    int j = 0;
    int swtch = 0;

    bool maze[maze_maxsize][maze_maxsize] = { 0, };  //set 0 is wall, 1 us path
    char buffer[buffersize];
    //memset(maze, 1, sizeof(maze));
    memset(buffer, 1, sizeof(buffer));
    FILE* txtin = fopen("MazeProb.txt", "r");
    //fgets(buffer, sizeof(buffer), txtin);
    fread(buffer, sizeof(char), sizeof(buffer), txtin);
    //fscanf(txtin, "%s %d", buffer, &num);


    char* cut = strtok(buffer, " ");
    h = atoi(cut);
    cut = strtok(NULL, "\n");
    w = atoi(cut);
    

    i = 0; j = 0;
    int c;
    for (c = 0; c < buffersize; c++) {
        
        if (buffer[c] == 48) { // if buffer = 0, maze = 1
            maze[i][j] = true;
            swtch = 1;
        }
        else if (buffer[c] == 49) { //if buffer = 1, maze = 0
            maze[i][j] = false;
            swtch = 1;
        }
        else if (buffer[c] == 1) break;
        else swtch = 0;
        if (swtch == 1) {
            j++;
            if (j == w) {
                j = 0; i++;
            }
            if (i == h) break;
        }
    }
    struct node* path[buffersize];
    int path_size = 0;
    path_size = findpath(0, 0, w - 1, h - 1, h-1, w-1, maze, path, path_size);
    printmaze(maze, h, w);
    printpath(path, path_size, 0,0,w-1,h-1);
    system("PAUSE");
}
