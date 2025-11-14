# Load the module
const SP = include("module.jl")

# Create a perceptron with 2 input features
p = SP.Perceptron(2, 0.1)

# Generate sample data (points above/below a line y = ax + b)
a, b = 0.5, 1
X = rand(1000, 2)  # 1000 points with 2 features each
y = map(x -> x[2] > a + b * x[1] ? 1 : -1, eachrow(X))

# Check initial accuracy
println("Initial accuracy: ", SP.accuracy(p, X, y))

# Train the model
SP.train!(p, X, y, epochs = 1000)

# Check final accuracy
println("Final accuracy: ", SP.accuracy(p, X, y))

# Extract learned parameters
ahat, bhat = p.weights[1] / p.weights[2], -p.weights[3] / p.weights[2]
println("Learned line: y = $ahat * x + $bhat")

# Optional: Visualize results
using Plots

# Plot the data points
scatter(X[:, 1], X[:, 2], 
        markercolor = map(x -> x == 1 ? :red : :blue, y),
        label = "Data points")

# Plot the real boundary
Plots.abline!(b, a, label = "Real line", linecolor = :red, linewidth = 2)

# Plot the learned boundary
Plots.abline!(bhat, ahat, label = "Learned line", linecolor = :green, linewidth = 2)
