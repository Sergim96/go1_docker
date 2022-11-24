FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu18.04

ARG SSH_PRIVATE_KEY
ARG SSH_PUBLIC_KEY
 
# Minimal setup
RUN apt-get update \
 && apt-get install -y locales lsb-release
ARG DEBIAN_FRONTEND=noninteractive
RUN dpkg-reconfigure locales
 
# Install ROS Melodic
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' 
RUN apt install -y curl
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - 
RUN apt-get update \
 && apt-get install -y --no-install-recommends ros-melodic-desktop-full
#RUN apt-get install -y --no-install-recommends python3-rosdep
RUN apt install -y python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential
RUN sudo apt -f install
RUN rosdep init \
 && rosdep fix-permissions \
 && rosdep update
RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc

#RUN apt install -y python3-pip
#RUN apt install -y python3-pip && pip3 install numpy pyyaml
#RUN apt install -y python3-catkin-pkg-modules python3-rospkg-modules
RUN apt-get update && \
    apt-get install -y \
        git \
        openssh-server \
        libmysqlclient-dev \
        vim 

# Authorize SSH Host
RUN mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh && \
    touch /root/.ssh/known_hosts
RUN ssh-keyscan github.com > /root/.ssh/known_hosts
# Add the keys and set permissions
RUN echo "$SSH_PRIVATE_KEY" > /root/.ssh/id_rsa && \
    echo "$SSH_PUBLIC_KEY" > /root/.ssh/id_rsa.pub && \
    chmod 600 /root/.ssh/id_rsa && \
    chmod 600 /root/.ssh/id_rsa.pub

# Install dependencies
RUN apt install -y liblcm-dev
WORKDIR /home/go1_ws/src
RUN git clone -b v3.8.0 https://github.com/unitreerobotics/unitree_legged_sdk.git
RUN cd unitree_legged_sdk
WORKDIR /home/go1_ws/src/unitree_legged_sdk
RUN mkdir build && cd build && cmake .. && make -j$(nproc) && make install
WORKDIR /home/go1_ws/src
RUN git clone -b v3.8.0 https://github.com/unitreerobotics/unitree_ros_to_real.git 
RUN git clone -b master https://github.com/unitreerobotics/unitree_ros.git
WORKDIR /home/go1_ws
RUN /bin/bash -c '. /opt/ros/melodic/setup.bash; catkin_make'

# personal setup 
RUN echo "source /home/go1_ws/devel/setup.bash" >> ~/.bashrc
RUN touch ~/.inputrc
RUN echo "\"\e[B\": history-search-forward" >> ~/.inputrc
RUN echo "\"\e[A\": history-search-backward" >> ~/.inputrc
RUN apt-get install -y bash-completion
