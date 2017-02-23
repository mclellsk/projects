#include <stdlib.h>
#include <GL/glut.h>
#include <gl/gl.h>
#include <stdio.h>
#include <Windows.h>
#include <list>
#include <time.h>
#include "Vector.h"
#include <iostream>

using namespace std;

#ifndef TRANSFORM_H
#define TRANSFORM_H

class Transform
{
public:
	static const float PI;

	Vector3 position;
	Vector3 rotation;
	Vector3 forward;
	Vector3 right;
	Vector3 up;

	Transform();
	Transform(Vector3 position);
	void Translate(Vector3 t);
	void Rotate(Vector3 axis, float angle);
	void RotateOnY(float angle);
	void RotateOnX(float angle);
	void RotateOnZ(float angle);
};

#endif