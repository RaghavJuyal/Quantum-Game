# complex.gd
extends Resource
class_name Complex

var re: float
var im: float

func _init(r: float = 0.0, i: float = 0.0):
	re = r
	im = i

func add(other: Complex) -> Complex:
	return Complex._create(re + other.re, im + other.im)

func sub(other: Complex) -> Complex:
	return Complex._create(re - other.re, im - other.im)

func mul(other: Complex) -> Complex:
	return Complex._create(re * other.re - im * other.im, re * other.im + im * other.re)

func div(other: Complex) -> Complex:
	var denom = other.re * other.re + other.im * other.im
	if denom == 0:
		push_error("Division by zero in Complex.div()")
		return Complex._create(0,0)
	return Complex._create(
		(re * other.re + im * other.im) / denom,
		(im * other.re - re * other.im) / denom
	)

func clone() -> Complex:
	return Complex._create(re, im)

func equals(other: Complex, tol: float = 1e-4) -> bool:
	return abs(re - other.re) < tol and abs(im - other.im) < tol

func conjugate() -> Complex:
	return Complex._create(re, -im)

func abs() -> float:
	return sqrt(re * re + im * im)

# --- Static helper for internal instance creation ---
static func _create(r: float, i: float) -> Complex:
	var c = Complex.new()
	c.re = r
	c.im = i
	return c
	
