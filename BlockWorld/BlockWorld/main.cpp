/*
 * Particle Engine
 * by Sean Mclellan
 *
 * Instructions are listed on the console upon compile.
 *
 */

#include <stdlib.h>
#include <GL\glut.h>
#include <gl/gl.h>
#include <stdio.h>
#include <Windows.h>
#include <vector>
#include <iostream>
#include <string>
#include <sstream>
#include <cmath>
#include "block.h"
#include "Vector.h"
#include "Transform.h"
#include "Colour.h"
using namespace std;

const int CAMSPEED = 5;
const int LENGTH = 60;
const int WIDTH = 60;

Transform camera(Vector3(-25, 0, -100));

int currentMaxHeight = 0;
int heightPerIter = 5;
int maxCircleSize = 20;
int scale = 1;

vector<Block> tiles;

int heightMap [LENGTH][WIDTH];

//Light Position
float light0[] = {0.0f, -25.0f, 0.0f, 0.0f};
//Light Properties
float amb0[] = {0.5f, 0.5f, 0.5f, 1.0f};
float diff0[] = {1, 1, 1, 1};
float spec0[] = {1, 1, 1, 1};
//Light Position
float light1[] = { -50.0f, -10.0f, -50.0f, 0.0f };
//Light Properties
float amb1[] = { 1.0f, 1.0f, 1.0f, 1.0f };
float diff1[] = { 0.5, 0.5, 0.5, 1 };
float spec1[] = { 0.5, 0.5, 0.5, 1 };

void keyboard(unsigned char key, int x, int y)
{
	//Forward
	if (key == '8')
		camera.Translate(camera.forward * CAMSPEED);
	//Backward
	if (key == '2')
		camera.Translate(-camera.forward * CAMSPEED);
	//Turn Left
	if (key == '7')
		camera.RotateOnY(CAMSPEED);
	//Turn Right
	if (key == '9')
		camera.RotateOnY(-CAMSPEED);
	//Left
	if (key == '4')
		camera.Translate(-camera.right * CAMSPEED);
	//Right
	if (key == '6')
		camera.Translate(camera.right * CAMSPEED);
	//Look Down
	if (key == 'w')
		camera.RotateOnX(CAMSPEED);
	//Look Up
	if (key == 's')
		camera.RotateOnX(-CAMSPEED);

	cout << camera.up.ToString() << endl;
}

void special(int key, int x, int y)
{
	switch(key)
	{
		case GLUT_KEY_UP:
			camera.Translate(camera.up * CAMSPEED);
			break;
		case GLUT_KEY_DOWN:
			camera.Translate(-camera.up * CAMSPEED);
			break;
	}
}

void cameraInitialize()
{
	glLoadIdentity();
	//Rotate around x-axis
	glRotatef(camera.rotation.x, camera.right.x, camera.right.y, camera.right.z);
	//Rotate around y-axis
	glRotatef(camera.rotation.y, camera.up.x, camera.up.y, camera.up.z);
	//Rotate around z-axis
	glRotatef(camera.rotation.z, camera.forward.x, camera.forward.y, camera.forward.z);
	//Translate to position
	glTranslatef(camera.position.x, camera.position.y, camera.position.z);
}

void circlesAlgorithm()
{
	for (int i = 0; i < WIDTH; i++)
			for (int j = 0; j < LENGTH; j++)
				heightMap[i][j] = 1;

	for (int k = 0; k < WIDTH*2; k++)
	{
		//Get a random point within the boundaries
		int x = (rand() % (WIDTH - 1));
		int z = (rand() % (LENGTH - 1));

		float pd;
		for (int i = 0; i < WIDTH; i++)
		{
			for (int j = 0; j < LENGTH; j++)
			{
				pd = (pow((x - (float)i), 2) + pow((z - (float)j), 2)) / (float)maxCircleSize;
				if (fabs(pd) <= 1.0)
				{
					heightMap[i][j] += (int)((heightPerIter / 2.0f) + cos(pd * 3.14) * (heightPerIter / 2.0f));
					if (heightMap[i][j] > currentMaxHeight)
						currentMaxHeight = heightMap[i][j];
				}
			}
		}
	}
}

void initializeMap()
{
	circlesAlgorithm();
	for (int i = 0; i < LENGTH; i++)
	{
		for (int j = 0; j < WIDTH; j++)
		{
			for (int k = 0; k < heightMap[i][j]; k++)
			{
				Vector3 pos = Vector3(i, k, j);
				float height = k / (float)currentMaxHeight;
				float r = 0, g = 1.0, b = 0;
				if (height <= 0.3f)
				{
					b = 1.0f - height;
					g = height;
				}
				else if (height > 0.3f && height <= 0.6f)
				{
					g = height;
				}
				else if (height > 0.6f)
				{
					g = 0.33f - abs(0.66f - height);
					r = height;
				}
				
				tiles.push_back(Block(pos, Colour(r, g, b, 1.0f), scale));
			}
		}
	}
}

void initLighting()
{
	glEnable(GL_SMOOTH);
	glShadeModel(GL_SMOOTH);
	glEnable(GL_LIGHT0);
	glLightfv(GL_LIGHT0, GL_POSITION, light0);
	glLightfv(GL_LIGHT0, GL_AMBIENT, amb0);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, diff0);
	glLightfv(GL_LIGHT0, GL_SPECULAR, spec0);
	glEnable(GL_LIGHT1);
	glLightfv(GL_LIGHT1, GL_POSITION, light1);
	glLightfv(GL_LIGHT1, GL_AMBIENT, amb1);
	glLightfv(GL_LIGHT1, GL_DIFFUSE, diff1);
	glLightfv(GL_LIGHT1, GL_SPECULAR, spec1);
	glEnable(GL_LIGHTING);
}

void display()
{
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	initLighting();
	cameraInitialize();

	for (unsigned int i = 0; i < tiles.size(); i++)
			tiles.at(i).drawCube();

	glutSwapBuffers();
	glutPostRedisplay();
}

int main(int argc, char** argv)
{
	printf("Block World\n");
	printf("---------------------------------\n");
	printf("COMMANDS:\n");
	cout << "8 - forward | 2 - backward" << endl;
	cout << "4 - left | 6 - right" << endl;
	cout << "7 - turn left | 9 - turn right" << endl;
	cout << "Up Arrow - move up | Down Arrow - move down" << endl;
	cout << "W - turn up | S - turn down" << endl;

	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH);
	glutInitWindowSize(480, 320);
	glutInitWindowPosition(0,0);
	glutCreateWindow("Block World");	

	glutKeyboardFunc(keyboard);
	glutSpecialFunc(special);

	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(45,1,1,1000);
	glPopMatrix();

	glClearColor(0, 0.5f, 1.0f, 1.0f);
	glMatrixMode(GL_MODELVIEW);

	initializeMap();

	glutDisplayFunc(display);

	glEnable(GL_DEPTH_TEST);
	glEnable(GL_CULL_FACE);

	glCullFace(GL_FRONT);

	glutMainLoop();				
	return(0);					
}

