修改日期：2025/4/18 陈俊儒
主要改动：将gps数据存储为geometry_msgs/PoseStamped的形式，并以发布为/gps_node/gps_traj话题，可以和雷达、IMU数据一起录制
增加了MATLAB文件处理存到rosbag的数据，输入为rosbag所在文件路径以及方法的名称（如fast-lio），输出为tum格式的txt轨迹文件
