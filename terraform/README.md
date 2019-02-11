# What's This?

I'm learning to deploy with terraform, and don't want to keep messing with the configuration on my machine.

Thus, I'm going to build myself a image with the correct configuration to run terrafrom commands & provision infrastructure in my AWS account.

Is this good practice? Who knows, but it sounds good to me.

# Directions to build image

docker build . -t terraform

docker run -it <image_id>

garrett-terraform

terraform plan \
	-var key_name="garrett-terraform"