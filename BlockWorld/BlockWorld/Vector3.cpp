#include "Vector.h"

Vector3::Vector3() {}

Vector3::Vector3(float x, float y, float z)
{
	this->x = x;
	this->y = y;
	this->z = z;
}

Vector3 Vector3::UnitVector()
{
	float mag = Magnitude();
	return Vector3(x / mag, y / mag, z / mag);
}

float Vector3::Magnitude()
{
	return sqrtf(pow(x, 2) + pow(y, 2) + pow(z, 2));
}

Vector3 Vector3::One()
{
	return Vector3(1, 1, 1);
}

Vector3 Vector3::Zero()
{
	return Vector3(0, 0, 0);
}

Vector3 Vector3::Up()
{
	return Vector3(0, -1, 0);
}

Vector3 Vector3::Right()
{
	return Vector3(-1, 0, 0);
}

Vector3 Vector3::Forward()
{
	return Vector3(0, 0, 1);
}

Vector3 Vector3::operator+(Vector3 vector)
{
	Vector3 result;
	result.x = x + vector.x;
	result.y = y + vector.y;
	result.z = z + vector.z;
	return result;
}

Vector3 Vector3::operator*(float scalar)
{
	Vector3 result;
	result.x = x * scalar;
	result.y = y * scalar;
	result.z = z * scalar;
	return result;
}

Vector3 Vector3::operator*(int scalar)
{
	Vector3 result;
	result.x = x * scalar;
	result.y = y * scalar;
	result.z = z * scalar;
	return result;
}

Vector3 Vector3::operator-()
{
	Vector3 result;
	result.x = -x;
	result.y = -y;
	result.z = -z;
	return result;
}

string Vector3::ToString()
{
	std::ostringstream ss;
	ss << "x:";
	ss << x;
	ss << " y:";
	ss << y;
	ss << " z:";
	ss << z;
	return ss.str();
}
