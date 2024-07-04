#ifndef __GPS_HPP
#define __GPS_HPP


#include <iostream>
#include <boost/asio.hpp>
#include <thread>
#include <chrono>
#include <sstream>

typedef unsigned char uchar;



using boost::asio::serial_port;
class GPS{
public:
    GPS() = default;
    explicit GPS(std::string dev); // construct func.
    void process(void);   // read IM1253's reply;
    double utc_time;
    double longitude, latitude, altitude;   // 
    double satellite_number;
    double hhop;            // horizontal dilution of precision; <2, good; 2-5, fine; 5-10, medium; 10-20, bad; 20+, very bad.
    double mode;            // working mode. 0, not working; 1, single; 2, RTK; 4, fixed base-station (Best, cm-level);  5, floating base (dm-level);


private:
    boost::asio::serial_port *sp_{};
    boost::asio::io_service ioSev_;
    std::string portName_;
    boost::system::error_code err_;

    bool parseGNVTG(const std::string& data) { return false; } // not implemented
    bool parseGNHDT(const std::string& data) { return false; } // not implemented
    bool parseGPRMC(const std::string& data) {return false;}    // not implemented;
    bool parseGPGGA(const std::string& data);

    bool checkSum(void);            // sum check.
};




#endif
