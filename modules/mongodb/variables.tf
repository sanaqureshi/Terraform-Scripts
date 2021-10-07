/*
N_Viriginia  (us-east-1) = "ami-087c17d1fe0178315"
Ohio         (us-east-2) = "ami-00dfe2c7ce89a450b"
N_California (us-west-1) = "ami-011996ff98de391d1"
Oregon       (us-west-2) = "ami-0c2d06d50ce30b442"
Mumbai       (ap-south-1) = "ami-0a23ccb2cdd9286bb"
Osaka        (ap-northeast-3) = "ami-09ec82600a05bc23a"
Seoul        (ap-northeast-2) = "ami-08c64544f5cfcddd0"
Singapore    (ap-southeast-1) = "ami-0210560cedcb09f07"
Sydney       (ap-southeast-1) = "ami-0210560cedcb09f07"
Tokyo        (ap-northeast-1) = "ami-02892a4ea9bfa2192"
Canada       (ca-central-1) = "ami-0e2407e55b9816758"
Frankfurt    (eu-central-1) = "ami-07df274a488ca9195"
Ireland      (eu-west-1) = "ami-0d1bf5b68307103c2"
London       (eu-west-2) = "ami-0dbec48abfe298cab"
Paris        (eu-west-3) = "ami-072056ff9d3689e7b"
Stockholm    (eu-north-1) = "ami-0f0b4cb72cf3eadf3"
Sao_Paulo    (sa-east-1) = "ami-09b9b17384f68fd7c"
*/

variable "ami" {
  type = string
}

variable "az" {
  type = string
}
