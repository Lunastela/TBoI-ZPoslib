
-- A simple 3D Vector class
---@class Vector3D
---@field X number
---@field Y number
---@field Z number
local Vector3D = {}
Vector3D.__index = Vector3D
Vector3D.__type = "Vector3D"

---@param X number
---@param Y number
---@param Z number
---@return Vector3D vector A 3D vector class
function Vector3D.Vector3D(X, Y, Z)
    return setmetatable({
        X = X or 0, 
        Y = Y or 0, 
        Z = Z or 0
    }, Vector3D)
end

---@param vector Vector
---@return Vector3D vector3D A 3D vector class
function Vector3D.From2D(vector)
    return Vector3D.Vector3D(vector.X, vector.Y, 0)
end

-- Vector Addition
function Vector3D.__add(a, b)
    return Vector3D.Vector3D(a.X + b.X, a.Y + b.Y, a.Z + b.Z)
end

-- Vector Subtraction
function Vector3D.__sub(a, b)
    return Vector3D.Vector3D(a.X - b.X, a.Y - b.Y, a.Z - b.Z)
end

-- Vector (scalar) multiplication
function Vector3D.__mul(a, b)
    -- Vector * Scalar multiplication
    if type(a) == "number" then
        return Vector3D.Vector3D(
            a * b.X, 
            a * b.Y, 
            a * b.Z
        )
    elseif type(b) == "number" then
        return Vector3D.Vector3D(
            a.X * b, 
            a.Y * b, 
            a.Z * b
        )
        -- Vector multiplication
    elseif getmetatable(a) == getmetatable(b) then
        return Vector3D.Vector3D(
            a.X * b.X, 
            a.Y * b.Y, 
            a.Z * b.Z
        )
    end
end

-- Vector Utility Methods

---@param b Vector3D
---@return number dotProduct The Dot Product of the vectors.
function Vector3D:Dot(b)
    return self.X * b.X + self.Y * b.Y + self.Z * b.Z
end

---@param b Vector3D
---@return Vector3D crossProduct The Cross Product of the vectors.
function Vector3D:Cross(b)
    return Vector3D.Vector3D(
        self.Y * b.Z - self.Z * b.Y,
        self.Z * b.X - self.X * b.Z,
        self.X * b.Y - self.Y * b.X
    )
end

function Vector3D:MagnitudeSquared()
    return self.X * self.X + self.Y * self.Y + self.Z * self.Z
end

function Vector3D.Magnitude(vector)
    return math.sqrt(vector:MagnitudeSquared())
end

function Vector3D:Normalized()
    local magnitude = self:Magnitude()
    if (magnitude <= 0) then
        return Vector3D.Vector3D(0, 0, 0)
    end
    return self * (1 / magnitude)
end

function Vector3D.DistanceSquared(a, b)
    local dx = a.X - b.X
    local dy = a.Y - b.Y
    local dz = a.Z - b.Z
    return dx * dx + dy * dy + dz * dz
end

function Vector3D:Distance(b)
    return math.sqrt(self:DistanceSquared(b))
end

local worldToScreenConversion = Isaac.WorldToScreenDistance(Vector.One)

---@return Vector vector
function Vector3D:To2D()
    return Vector(self.X, self.Y)
end

---@return Vector flattenedVector
function Vector3D:Flatten()
    return Vector(self.X, self.Y + (self.Z * worldToScreenConversion.Y))
end

-- Outputting Vectors in print statements
function Vector3D:__tostring()
    return string.format("Vector3D(%.2f, %.2f, %.2f)", self.X, self.Y, self.Z)
end

-- Rawset Vector Zero and One
rawset(Vector3D, "Zero", Vector3D.Vector3D(0, 0, 0))
rawset(Vector3D, "One", Vector3D.Vector3D(1, 1, 1))
rawset(Vector3D, "One2D", Vector3D.Vector3D(1, 1, 0))

return Vector3D