#include <stdlib.h>
#include <GL/glut.h>
#include <gl/gl.h>
#include <stdio.h>
#include <Windows.h>
#include <list>
#include <time.h>
#include <sstream>
using namespace std;

#ifndef VECTOR_H
#define VECTOR_H

class Vector3
{
public:
	float x;
	float y;
	float z;

	Vector3();
	Vector3(float x, float y, float z);
	static Vector3 Zero();
	static Vector3 One();
	float Magnitude();
	Vector3 UnitVector();
	static Vector3 Up();
	static Vector3 Right();
	static Vector3 Forward();
	Vector3 operator+(Vector3 vector);
	Vector3 operator*(float scalar);
	Vector3 operator*(int scalar);
	Vector3 operator-();
	string ToString();
};

#endif