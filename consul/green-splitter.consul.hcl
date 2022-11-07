Kind= "service-splitter"
Name = "app"
Splits = [
  {
    Weight = 50
    ServiceSubset = "blue"
  },
  {
    Weight = 50
    ServiceSubset= "green"
  }
]
