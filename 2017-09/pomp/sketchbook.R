p <- c('x0'=55, 'm'=2.56, 'sigma' = 8.23)
n <- 100

t = 1:n

x <- c(p['x0'])
for (i in 2:n) {
  x[i] <- x[i - 1] + p['m']
}

y <- c()
for (i in 1:n) {
  y[i] <- rnorm(1, x[i], sd = p['sigma'])
}

plot(y~t)

df <- data.frame(t, y)


library('pomp')
model <- pomp(data = df, times = 't', t0 = 1)
model <- pomp(model, statenames = c('x'), obsnames = c('y'), paramnames = c('x0', 'm', 'sigma'))

init <- function (params, t0, ...) {
   c('x' = params[['x0']])
}

model <- pomp(model, initializer = init)

rproc <- discrete.time.sim(
  step.fun = function(x, t, params, delta.t, ...) {
    return(x['x'] + params['m'] * delta.t)
  },
  delta.t = 1
)

model <- pomp(model, rprocess = rproc)

rmeas <- function (x, t, params, ...) {
  rnorm(1, mean = x['x'], sd = params['sigma'])
}

model <- pomp(model, rmeasure = rmeas)


 dmeas <- function(y, x, t, params, log, ...) {
   dnorm(x = y['y'], mean = x['x'], sd = params['sigma'], log=log)
 }

model <- pomp(model, dmeasure = dmeas)

f <- function(par) {
  -logLik(pfilter(model, params = par, Np = 2000))
}

fit <- optim(par = c('x0' = 50, 'sigma' = 5, 'm' = 2), fn = f)

simulate(model, params =c('x0'=55, 'sigma'=8.23, 'm' = 2.56), as.data.frame = T) -> sim; plot(sim$y~sim$time)
