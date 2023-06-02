library(animation)

# Function to calculate the magnetisation of the grid.
calculateMagnetisation <- function(grid) { 
  mean(grid) 
}

# Function to calculate the total energy of the grid. Takes into account periodic boundary conditions.
calculateEnergy <- function(grid, gridSize, coupling = 1) { 
  # Arrays to store the energy contribution of each row and column.
  energyRow <- numeric(gridSize) 
  energyColumn <- numeric(gridSize) 
  
  # Calculate energy contributions for each row and column, excluding the last one.
  for (i in seq_len(gridSize - 1)) { 
    energyRow[i] <- sum(-coupling * grid[i, ] * grid[i + 1, ])
    energyColumn[i] <- sum(-coupling * grid[, i] * grid[, i + 1])
  } 
  
  # Calculate energy contributions for the last row and column, wrapping around to the first.
  energyRow[gridSize] <- sum(-coupling * grid[gridSize, ] * grid[1, ])
  energyColumn[gridSize] <- sum(-coupling * grid[, gridSize] * grid[, 1])
  
  # Return total energy.
  sum(energyRow) + sum(energyColumn) 
}

# Function to calculate the change in energy if a given spin is flipped.
calculateEnergyDiff <- function(grid, gridSize, row, column, coupling = 1) {
  # Flip the spin.
  grid[row, column] <- -grid[row, column]
  energy <- numeric(4)
  
  # Calculate the change in energy due to interaction with the four neighbors.
  energy[1] <- -coupling * grid[row, column] * grid[row %% gridSize + 1, column]
  energy[2] <- -coupling * grid[row, column] * grid[(row - 2) %% gridSize + 1, column]
  energy[3] <- -coupling * grid[row, column] * grid[row, (column %% gridSize) + 1]
  energy[4] <- -coupling * grid[row, column] * grid[row, (column - 2) %% gridSize + 1]
  
  # Return total energy change.
  2 * sum(energy) 
}

# Function to animate the evolution of the Ising model grid over a given number of steps.
animateFlips <- function(gridSize, numSteps, temp, plotInterval) {
  # Boltzmann constant
  k <- 1
  
  # Thermodynamic beta
  beta <- 1 / (k * temp) 
  
  # Initialize the grid with random spins.
  grid <- matrix(sample(c(-1, 1), gridSize^2, replace = TRUE), gridSize, gridSize)
  
  # Animate and save the animation as a GIF.
  saveGIF({
    for (i in seq_len(numSteps)) {
      # Randomly select a spin.
      row <- sample(seq_len(nrow(grid)), 1)
      col <- sample(seq_len(ncol(grid)), 1)
      
      # Calculate energy change if this spin is flipped.
      energyChange <- calculateEnergyDiff(grid, gridSize, row, col)
      
      # Flip the spin if energy is reduced or Metropolis criterion is met.
      if (energyChange < 0 || runif(1) <= exp(-beta * energyChange)) {
        grid[row, col] <- -grid[row, col]
      }
      
      # Plot the grid state every 'plotInterval' steps.
      if (i %% plotInterval == 0) {
        image(seq_len(nrow(grid)), seq_len(ncol(grid)), t(grid), 
              xlab = "", ylab = "", main = paste("Step:", i), col = gray(0:1), 
              xaxt = 'n', yaxt = 'n')
        grid(nx = nrow(grid), ny = ncol(grid), col = "gray50", lty = 1)
      }
    }
  }, movie.name = "lattice_evolution.gif")
  
  # Return the final state of the grid, its energy, and magnetisation.
  list(
    finalState = grid, 
    finalEnergy = calculateEnergy(grid, gridSize), 
    finalMagnetisation = calculateMagnetisation(grid)
  )
}