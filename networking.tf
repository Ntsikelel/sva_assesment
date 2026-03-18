resource "aws_vpc" "sva_task_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name             = "sva_task"
    Enviroment       = "developement"
    Cost_Center      = "web-system-sva"
    Cost_Center_Code = "0001"
    Service_Name     = "web-api-sva"
    Owner            = "dev_sva_ntsikelelo_metseeme"
  }
}

resource "aws_subnet" "private_sbn_1a" {
  vpc_id            = aws_vpc.sva_task_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name             = "sva_private_subnet"
    Enviroment       = "developement"
    Cost_Center      = "web-system-sva"
    Cost_Center_Code = "0001"
    Service_Name     = "web-api-sva"
    Owner            = "dev_sva_ntsikelelo_metseeme"
  }
}
resource "aws_subnet" "private_sbn_1b" {
  vpc_id            = aws_vpc.sva_task_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name             = "sva_private_subnet"
    Enviroment       = "developement"
    Cost_Center      = "web-system-sva"
    Cost_Center_Code = "0001"
    Service_Name     = "web-api-sva"
    Owner            = "dev_sva_ntsikelelo_metseeme"
  }
}