
#include "gps.hpp"

#include <thread>
#include <linux/ioctl.h>

using namespace std;

GPS::GPS(std::string dev):portName_(std::move(dev)){
    try{
        sp_ = new serial_port(ioSev_, portName_);
        sp_->set_option(serial_port::baud_rate(115200));
        sp_->set_option(serial_port::flow_control(serial_port::flow_control::none));
        sp_->set_option(serial_port::parity(serial_port::parity::none));
        sp_->set_option(serial_port::stop_bits(serial_port::stop_bits::one));
        sp_->set_option(serial_port::character_size(8));
    }catch (...){
        std::cerr << "Exception Error: Cannot open port: "<<portName_ <<", did run 'chmod' before?"<< std::endl;
    }

    std::cout <<"GPS main process begin..." << std::endl;
    std::thread t1(&GPS::process, this);
    t1.detach();

}

void GPS::process(void){
    while(true){
        std::cout <<"Waiting for data" << std::endl;

        uchar dollar[1];        // $ 
        uchar mode[6];          // GNVTG, GNHDT, GPGGA, GPRMC
        boost::asio::streambuf buf;        // REAL data

        boost::asio::read(*sp_, boost::asio::buffer(dollar, 1));
        // first find the $, and then check GNVTG, GNHDT, GPGGA, GPRMC
        if(dollar[0] == '$'){
            cout << " Find `$` " << endl;
            boost::asio::read(*sp_, boost::asio::buffer(mode, 6));
            if (mode[0] == 'G' && mode[1] == 'P' && mode[2] == 'G' && mode[3] == 'G' && mode[4] == 'A' && mode[5] == ','){
                cout << "GPGGA Header get" << endl;
                // process GPGGA
                boost::asio::read_until(*sp_, buf, '*');
                cout << "GPGGA Data get" << endl;
                std::istream is(&buf);
                std::string data;
                std::getline(is, data, '*'); // Read up to the '*' character
                std::cout << "Received: " << data << std::endl;
                parseGPGGA(data);
            }
            if (mode[0] == 'G' && mode[1] == 'N' && mode[2] == 'V' && mode[3] == 'T' && mode[4] == 'G' && mode[5] == ','){
                cout << "GNVTG data get" << endl;
            }
            if (mode[0] == 'G' && mode[1] == 'N' && mode[2] == 'H' && mode[3] == 'D' && mode[4] == 'T' && mode[5] == ','){
                cout << "GNHDT data get" << endl;
            }
            if (mode[0] == 'G' && mode[1] == 'P' && mode[2] == 'R' && mode[3] == 'M' && mode[4] == 'C' && mode[5] == ','){
                cout << "GPRMC data get" << endl;
            }
            if (mode[0] == 'G' && mode[1] == 'P' && mode[2] == 'G' && mode[3] == 'G' && mode[4] == 'A' && mode[5] == ','){
                cout << "GPGGA data get" << endl;
            }
        }

        std::this_thread::sleep_for(std::chrono::milliseconds(10));


    }
}




//// GPGGA format:
// GPGGA
// hhmmss.ss: utc time
// llll.ll: ddmm.mmmm, longitude
// a: N or S
// yyyy.yy: ddmm.mmmm, algitude
// b: E or W
// q: quality (int)
// x: number of sittelite
// h: HDOP
// M: M(meter)
// m.m: elevation
// M: M(meter)
// sss: (差分GPS数据的年龄（无效时为空）)
// ccc: (差分站ID（无效时为空）)
// *
// sum1, sum2


bool GPS::parseGPGGA(const std::string& raw_gpgga){
    std::stringstream ss(raw_gpgga);
    std::string item;
    std::vector<std::string> parsed_data;

    while (std::getline(ss, item, ',')){
        parsed_data.push_back(item);
    }

    for(auto data:parsed_data){
        cout << raw_gpgga << endl;
    }

    return true;
}
