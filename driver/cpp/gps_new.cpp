#include "gps.hpp"
#include <thread>
#include <linux/ioctl.h>
#include <fstream>
#include <tf/tf.h>
#include <geographic_msgs/GeoPoint.h>
#include <geodesy/utm.h>
#include <geodesy/wgs84.h>
#include <nav_msgs/Odometry.h>
#include <sensor_msgs/NavSatFix.h>
#include <sensor_msgs/NavSatStatus.h>
#include <std_msgs/Float64.h>
#include <vector>
bool GPS_SIGNAL = false; // 定义全局变量
double global_heading = 0.0; // 定义全局变量来存储航向角
bool heading_received = false; // 标记是否收到了航向角

using namespace std;//释放命名空间std

GPS::GPS(std::string dev) : portName_(std::move(dev)), nh_("~"), initial_set_(false) {
    gps_pub_ = nh_.advertise<std_msgs::Float64>("gps_status", 20);//创建发布者，<>内是发布的信息类型，（主题名字，发布队列大小）
    try {
        sp_ = new serial_port(ioSev_, portName_);
        sp_->set_option(serial_port::baud_rate(115200));
        sp_->set_option(serial_port::flow_control(serial_port::flow_control::none));
        sp_->set_option(serial_port::parity(serial_port::parity::none));
        sp_->set_option(serial_port::stop_bits(serial_port::stop_bits::one));
        sp_->set_option(serial_port::character_size(8));
    } catch (...) {
        std::cerr << "Exception Error: Cannot open port: " << portName_ << ", did run 'chmod' before?" << std::endl;
    }

    std::cout << "GPS main process begin..." << std::endl;
    std::thread t1(&GPS::process, this);
    t1.detach();
}

void GPS::process(void) {
    std::stringstream ss;
    ss<<std::fixed<<std::setprecision(4);
    ss << ros::Time::now().toSec();
    std::string str = ss.str();//获取ros时间用于文件命名
    while (true) {    
        boost::asio::streambuf buf;   
        boost::asio::read_until(*sp_, buf, "*");
        std::istream is(&buf);
        std::string core_data;
        //boost::asio::read(*sp_, boost::asio::buffer(check_sum, 3));

        
        while (std::getline(is, core_data)){
                 //ROS_INFO_STREAM("core_data: " << core_data);
                 std::vector<double> enup(4);
 		  std_msgs::Float64 msg_status;
                 if (core_data[0] == '$' && core_data[1] == 'G' && core_data[2] == 'P' && core_data[3] == 'G' && core_data[4] == 'G' && core_data[5] == 'A') {
                        try{
                            parseGPGGA_new(core_data, enup);
                        } 
                        catch (...) {
    		      		std::cerr << "Invalid input for conversion to double." << std::endl;
    			 }
    		     msg_status.data = enup[3] ;
   		     gps_pub_.publish(msg_status);
   		     ROS_INFO_STREAM("mode:" << enup[3]);
                    std::ofstream outfile;
                    std::string filename;
                    filename = "/home/scout/ouster_ws/data/" + str + ".txt";
                    outfile.open(filename, std::ios_base::app);
                    outfile<<std::fixed<<std::setprecision(9);
                    outfile << ros::Time::now().toSec() <<" "<< enup[0]<<" "<< enup[1]<<" "<< enup[2]<<" "<<'1'<<" "<<'0'<<" "<<'0'<<" "<<'0' << std::endl;
         	}
                }
                 
    }
}

bool GPS::parseGPGGA_new(const std::string& raw_gpgga, std::vector<double>& position_enu) {
    std::stringstream ss(raw_gpgga);
    std::string item;
    std::vector<std::string> parsed_data;
   
    while (std::getline(ss, item, ',')) {
        parsed_data.push_back(item);
    }

    string utc_str = parsed_data[1];
    string lati_str = parsed_data[2];
    string long_str = parsed_data[4];
    string alti_str = parsed_data[9];
    mode = stod(parsed_data[6]);

    latitude = stod(lati_str.substr(0, 2)) + stod(lati_str.substr(2)) / 60.0f;
    longitude = stod(long_str.substr(0,3)) + stod(long_str.substr(3)) / 60.0f;
    altitude = stod(alti_str);
	
    // ENU 坐标转换
    geographic_msgs::GeoPoint current_geo_point;
    current_geo_point.latitude = latitude;
    current_geo_point.longitude = longitude;
    current_geo_point.altitude = altitude;

    geodesy::UTMPoint current_utm_point;
    geodesy::fromMsg(current_geo_point, current_utm_point);

   if (!initial_set_) {
        initial_utm_point_ = current_utm_point;
        initial_set_ = true;
    }

//发布实际位置坐标信息
    nav_msgs::Odometry odom_msg;
    odom_msg.header.stamp = ros::Time::now();
    odom_msg.header.frame_id = "odom";
    odom_msg.pose.pose.position.x = current_utm_point.easting - initial_utm_point_.easting;
    odom_msg.pose.pose.position.y = current_utm_point.northing - initial_utm_point_.northing;
    odom_msg.pose.pose.position.z = altitude - initial_utm_point_.altitude;
    position_enu[0] =odom_msg.pose.pose.position.x;
    position_enu[1] =odom_msg.pose.pose.position.y; 
    position_enu[2] =odom_msg.pose.pose.position.z;
    position_enu[3] =mode;
    return true;
}

