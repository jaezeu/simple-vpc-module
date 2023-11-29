resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

################################ PUBLIC SUBNET INFRA ###################################################################

resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.name_prefix}-public"
  }
}

resource "aws_route_table" "Public-Subnet-RT" {
  count  = length(var.public_subnet_cidrs) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Route Table for ${var.name_prefix}-public subnets"
  }
}

resource "aws_route" "internet_gateway" {
  count = length(var.public_subnet_cidrs) > 0 ? 1 : 0

  route_table_id         = aws_route_table.Public-Subnet-RT[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "RT-IG-Association" {
  count          = length(var.public_subnet_cidrs) > 0 ? length(var.public_subnet_cidrs) : 0
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.Public-Subnet-RT[0].id
}


################################ PRIVATE SUBNET INFRA ###################################################################

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.name_prefix}-private"
  }
}

resource "aws_eip" "natgw" {
  count  = var.create_natgw ? 1 : 0
  domain = "vpc"

  tags = {
    Name = "${var.name_prefix}-eip"
  }
}

resource "aws_nat_gateway" "natgw" {
  count         = length(var.public_subnet_cidrs) > 0 && length(var.private_subnet_cidrs) > 0 && var.create_natgw ? 1 : 0
  allocation_id = aws_eip.natgw[0].id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name = "${var.name_prefix}-nat"
  }
}

resource "aws_route_table" "Private-Subnet-RT" {
  count  = length(var.private_subnet_cidrs) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Route Table for ${var.name_prefix}-private subnets"
  }
}

resource "aws_route_table_association" "RT-Private-Association" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.Private-Subnet-RT[0].id
}

################################ DB SUBNET INFRA ###################################################################

resource "aws_subnet" "db" {
  count             = length(var.db_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.db_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.name_prefix}-private"
  }
}


resource "aws_route_table" "DB-Subnet-RT" {
  count  = length(var.db_subnet_cidrs) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Route Table for ${var.name_prefix}-db subnets"
  }
}

resource "aws_route_table_association" "RT-DB-Association" {
  count          = length(var.db_subnet_cidrs)
  subnet_id      = element(aws_subnet.db[*].id, count.index)
  route_table_id = aws_route_table.DB-Subnet-RT[0].id
}