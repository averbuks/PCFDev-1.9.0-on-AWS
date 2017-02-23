SfnRegistry.register(:instance_types) do
  [
    't2.medium',
    't2.large',
	't2.xlarge',
	't2.2xlarge'
	
  ]
end
SfnRegistry.register(:instance_type_default){ 't2.medium' }

SparkleFormation.new('pcfdev-1.9.0-aw') do
  description "AWS CloudFormation pcfdev-1.9.0-aws.rb created by avermk (markkrishka@gmail.com)"

  #parameters for cloudformation
  parameters do
    key_name do
      description 'Name of an existing EC2 KeyPair to enable SSH access to the instances'
      type 'String'
    end
	instance_type do
      type 'String'
      allowed_values registry!(:instance_types)
	  default registry!(:instance_type_default)
	end
	domain_name do
	  description 'Please, enter FQDN of your, please check that *.your.domain.name can be resolved in Public IP, You will have to assign IEP to this instance manually, if it is needed!'
      type 'String'
	end
	
  end

  #region mappings
  mappings.region_map do
    set!('us-west-2'._no_hump, :ami => 'ami-4766e627')
  end


# instance
  dynamic!(:ec2_instance, :pcfdev) do
    type 'AWS::EC2::Instance'
    properties do
      key_name ref!(:key_name)
	  availability_zone 'us-west-2a'
	  image_id map!(:region_map, region!, :ami)
	  instance_type ref!(:instance_type)
      user_data base64!(ref!(:domain_name))
	  security_group_ids [ref!(:pcfdev_ec2_security_group)]
    end
  end
  

#security group for ec2 instances
  dynamic!(:ec2_security_group, :pcfdev) do
	properties do
	group_description "Security group for PCFDev instance"
	end
  end
#inbound rules for security group, allow tcp 22 from Mins office and tcp 80 from anywhere 
  dynamic!(:ec2_security_group_ingress, 'pcfdev_ec2_http',
	           :from_port => '80',
			   :to_port => '80',
	           :ip_protocol => 'tcp',
	           :group_name => ref!(:pcfdev_ec2_security_group),
	           :cidr_ip => '0.0.0.0/0'
	  )
  dynamic!(:ec2_security_group_ingress, 'pcfdev_ec2_https',
	           :from_port => '443',
			   :to_port => '443',
	           :ip_protocol => 'tcp',
	           :group_name => ref!(:pcfdev_ec2_security_group),
	           :cidr_ip => '0.0.0.0/0'
	  )
  dynamic!(:ec2_security_group_ingress, 'pcfdev_ec2_ssh',
	           :from_port => '22',
			   :to_port => '22',
	           :ip_protocol => 'tcp',
	           :group_name => ref!(:pcfdev_ec2_security_group),
	           :cidr_ip => '0.0.0.0/0'
	  )
  dynamic!(:ec2_security_group_ingress, 'pcfdev_ec2_ssh_proxy',
	           :from_port => '2222',
			   :to_port => '2222',
	           :ip_protocol => 'tcp',
	           :group_name => ref!(:pcfdev_ec2_security_group),
	           :cidr_ip => '0.0.0.0/0'
	  )
  dynamic!(:ec2_security_group_ingress, 'pcfdev_ec2_mysql',
	           :from_port => '3306',
			   :to_port => '3306',
	           :ip_protocol => 'tcp',
	           :group_name => ref!(:pcfdev_ec2_security_group),
	           :cidr_ip => '0.0.0.0/0'
	  )
	  

#outputs which will appear after stack creation on AWS console
  outputs do


    pcf_dev_api do
      description 'Availability Zone of the newly created EC2 instance'
      value join!('cf login -a https://api.',ref!(:domain_name),' --skip-ssl-validation')
    end
	pcf_dev_apps_manager do
      description 'Availability Zone of the newly created EC2 instance'
      value join!('https://apps.',ref!(:domain_name)) 
    end
 
  end
end