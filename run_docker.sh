docker run -it --net=host \
	   -e DISPLAY=$DISPLAY \
           -v /tmp/.X11-unix/:/tmp/.X11-unix/ \
           go1_dev \
