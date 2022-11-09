Kind= "service-splitter"
Name = "app"
Splits = [
  {
    Weight = 100
    ServiceSubset = "blue"
  },
  {
    Weight = 0
    ServiceSubset= "green"
  }
]
