# Create VPC for environment
resource "aws_vpc" "infra" {
  cidr_block           = "${var.vpc_net_block}.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "${var.environment} VPC"
  }
}

# Create Public Subnets
resource "aws_subnet" "PublicSubnet" {
  count                   = "${length(var.deploy_availability_zones)}"
  vpc_id                  = "${aws_vpc.infra.id}"
  availability_zone       = "${var.deploy_availability_zones[count.index]}"
  cidr_block              = "${var.vpc_net_block}${var.public_subnet_cidrs[count.index]}"
  map_public_ip_on_launch = false

  tags {
    Name = "${var.environment} Public Subnet ${count.index+1}"
  }
}

output "PublicSubnetIDs" {
  value = "${aws_subnet.PublicSubnet.*.id}"
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = "${aws_vpc.infra.id}"

  tags {
    Name = "${var.environment} IGW"
  }
}

resource "aws_route_table" "PublicRouteTable" {
  vpc_id = "${aws_vpc.infra.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.IGW.id}"
  }

  route {
    cidr_block                = "${var.default_vpc_cidrs}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.defaultPeering.id}"
  }
}

resource "aws_route_table_association" "PublicRouteTableAssoc" {
  count          = "${aws_subnet.PublicSubnet.count}"
  subnet_id      = "${element(aws_subnet.PublicSubnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.PublicRouteTable.id}"
}

# Create Private Subnets
resource "aws_subnet" "PrivateSubnet" {
  count                   = "${length(var.deploy_availability_zones)}"
  vpc_id                  = "${aws_vpc.infra.id}"
  availability_zone       = "${var.deploy_availability_zones[count.index]}"
  cidr_block              = "${var.vpc_net_block}${var.private_subnet_cidrs[count.index]}"
  map_public_ip_on_launch = false

  tags {
    Name = "${var.environment} Private Subnet ${count.index+1}"
  }
}

output "PrivateSubnetIDs" {
  value = "${aws_subnet.PrivateSubnet.*.id}"
}

resource "aws_eip" "NGW_EIP" {
  tags {
    Name = "${var.environment} NGW EIP"
  }
}

resource "aws_nat_gateway" "NGW" {
  subnet_id     = "${element(aws_subnet.PublicSubnet.*.id, var.nat_subnet_number)}"
  allocation_id = "${aws_eip.NGW_EIP.id}"

  tags {
    Name = "${var.environment} NGW"
  }
}

resource "aws_route_table" "PrivateRouteTable" {
  vpc_id = "${aws_vpc.infra.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.NGW.id}"
  }

  route {
    cidr_block                = "${var.default_vpc_cidrs}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.defaultPeering.id}"
  }
}

resource "aws_route_table_association" "PrivateRouteTableAssoc" {
  count          = "${aws_subnet.PrivateSubnet.count}"
  subnet_id      = "${element(aws_subnet.PrivateSubnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.PrivateRouteTable.id}"
}

# peering env VPC with default VPC where jenkins executes terraform to create instances and invokes anisble
resource "aws_vpc_peering_connection" "defaultPeering" {
  peer_owner_id = "611982896649"          # Change this with your AWS account ID
  peer_vpc_id   = "${var.default_vpc_id}"
  vpc_id        = "${aws_vpc.infra.id}"
  auto_accept   = true

  tags {
    Name = "${var.environment} to default"
  }
}

resource "aws_vpc_peering_connection_accepter" "defaultPeering" {
  vpc_peering_connection_id = "${aws_vpc_peering_connection.defaultPeering.id}"
  auto_accept               = true

  tags {
    Name = "${var.environment} to default"
  }
}

resource "aws_route" "defaultPeeringRoutes" {
  route_table_id            = "${var.defaultRouteTables}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.defaultPeering.id}"
  destination_cidr_block    = "${aws_vpc.infra.cidr_block}"
}
