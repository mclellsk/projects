#include "Transform.h"

const float Transform::PI = 3.1415926f;

Transform::Transform() 
{
	this->position = Vector3::Zero();
	this->up = Vector3::Up();
	this->forward = Vector3::Forward();
	this->right = Vector3::Right();
}

Transform::Transform(Vector3 position)
{
	this->position = Vector3(position.x, position.y, position.z);
	this->up = Vector3::Up();
	this->forward = Vector3::Forward();
	this->right = Vector3::Right();
}

//Translate transform relative to position
void Transform::Translate(Vector3 t)
{
	this->position = this->position + t;
}

//Rotate transform around local axis
//Angle in degrees
void Transform::Rotate(Vector3 axis, float angle)
{
	//Get axis relative to current position of transform
	float rad = angle / (180.0f / Transform::PI);
	float r[3][3];

	//newPosition = R * position

	r[0][0] = cos(rad) + pow(axis.x, 2) * (1 - cos(rad));
	r[0][1] = axis.x * axis.y * (1 - cos(rad)) - axis.z * sin(rad);
	r[0][2] = axis.x * axis.z * (1 - cos(rad)) + axis.y * sin(rad);
	r[1][0] = axis.y * axis.x * (1 - cos(rad)) + axis.z * sin(rad);
	r[1][1] = cos(rad) + pow(axis.y, 2) * (1 - cos(rad));
	r[1][2] = axis.y * axis.z * (1 - cos(rad)) - axis.x * sin(rad);
	r[2][0] = axis.z * axis.x * (1 - cos(rad)) - axis.y * sin(rad);
	r[2][1] = axis.z * axis.y * (1 - cos(rad)) + axis.x * sin(rad);
	r[2][2] = cos(rad) + pow(axis.z, 2) * (1 - cos(rad));

	Vector3 newPosition = Vector3();

	//Rotate local forward vector around axis
	newPosition.x = r[0][0] * forward.x + r[0][1] * forward.y + r[0][2] * forward.z;
	newPosition.y = r[1][0] * forward.x + r[1][1] * forward.y + r[1][2] * forward.z;
	newPosition.z = r[2][0] * forward.x + r[2][1] * forward.y + r[2][2] * forward.z;
	forward = newPosition;

	//Rotate local up vector around axis
	newPosition.x = r[0][0] * up.x + r[0][1] * up.y + r[0][2] * up.z;
	newPosition.y = r[1][0] * up.x + r[1][1] * up.y + r[1][2] * up.z;
	newPosition.z = r[2][0] * up.x + r[2][1] * up.y + r[2][2] * up.z;
	up = newPosition;

	//Rotate local right vector around axis
	newPosition.x = r[0][0] * right.x + r[0][1] * right.y + r[0][2] * right.z;
	newPosition.y = r[1][0] * right.x + r[1][1] * right.y + r[1][2] * right.z;
	newPosition.z = r[2][0] * right.x + r[2][1] * right.y + r[2][2] * right.z;
	right = newPosition;
}

void Transform::RotateOnX(float angle)
{
	this->rotation.x = (int)(this->rotation.x + angle) % 360;
	Transform::Rotate(-this->right, (int)angle % 360);
}

void Transform::RotateOnY(float angle)
{
	this->rotation.y = (int)(this->rotation.y + angle) % 360;
	Transform::Rotate(-this->up, (int)angle % 360);
}

void Transform::RotateOnZ(float angle)
{
	this->rotation.z = (int)(this->rotation.z + angle) % 360;
	Transform::Rotate(this->forward, (int)angle % 360);
}