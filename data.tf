/* data "aws_vpc" "selected" {
  filter {
    name = "tag:Name"
    values = ["vpc-test-vpc"]
  }
}
 */
data "aws_subnet" "subnet1" {
  filter {
    name = "tag:Name"
    values = ["vpc-test-subnet-private1-us-east-1a"]
  }
}

  data "aws_subnet" "subnet2" {
  filter {
    name = "tag:Name"
    values = ["vpc-test-subnet-private2-us-east-1b"]
  }
}


 