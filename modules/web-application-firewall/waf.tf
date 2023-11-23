locals {
  cidr_whitelist = [
    "47.187.65.253/32",  # James Feigel - lw
    "47.185.179.252/32", # James Feigel - fm
    "76.183.235.6/32",   # Ted Howard
    "69.222.113.85/32",  # Brant Carthel
    "69.216.110.69/32",  # Andrew Turner
    "69.216.110.69/32",  # Andrew Turner Hotspot
    "35.137.171.255/32", # Andrew Turner - 3
    "76.202.242.146/32", # David Wood - 1
    "209.10.188.165/32", # David Wood - 2
    "45.26.165.24/32",   # Teresa Underhill
    "35.134.92.193/32",   # Teresa Underhill
    "209.10.188.165/32", # Adam Watson
    "71.132.162.164/32", # Adam Watson 2
    "97.105.31.26/32",   # Dialexa's Static IP (Allegedly)
    "97.77.55.170/32",   # Dialexa 1
    "97.105.31.26/32",   # Dialexa 2
    "99.116.11.64/32",   # Velan Packianathan
    "107.77.201.227/32", # ?
    "52.128.53.186/32",  # Trevor / Stacie
    "108.73.145.152/32", # Trevor / Stacie
    "108.70.204.161/32", # Stacie George
    "209.10.188.190/32", # Morsco Guest Wifi
    "10.255.201.104/32", # David Meyers
    "72.181.149.6/32",   # Elliot Rotwein - dallas
    "76.176.115.51/32",  # Elliot Rotwein - sd
    "160.3.48.78/32",  # Elliot Rotwein - temp
    "75.38.52.48/32",    # Mark Kunkle
    "209.10.188.190/32", # Morsco Guest Wifi
    "10.255.201.104/32", # David Meyers
    "75.57.25.109/32",   # Analyst
    "209.10.188.165/32", # Zienat Alang
    "76.184.245.199/32", # Kavitha
    "104.13.125.130/32", # Prachi
    "76.85.100.226/32",  # Tripura
    "76.85.35.31/32",    # Erik Wendland
    "10.7.58.103/32",    # Jared Wade
    "73.6.31.101/32",    # AJ
    "208.185.77.187/32", # Jared Wade
    "98.42.205.33/32",   # Amod Setlur (Auryc)
    "98.37.251.81/32",   # Amod Setlur (Auryc)
    "72.191.45.77/32",   # Tripura #2
    "47.185.231.202/32", # Feun
    "150.221.188.129/32", # Richard Chang
    "209.10.188.165/32", # Richard Chang
    "98.220.20.11/32", # Rija Aamir
    "209.10.136.165/32", # Prachi , Richard
    "70.120.207.42/32", # Patrick McCollum
    "70.241.245.156/32", # Cheryl Huckabay
    "149.167.150.138/32", # Agency helping w/ rollback
    "67.11.89.238/32", # Patricia Moturi-Taylor
    "107.139.59.219/32", # Sadia Hassan
    "173.247.186.74/32", # Robert Ferguson
    "23.243.38.17/32", # Robert Ferguson
    "47.186.1.108/32", # Jackson McComas
    "76.183.153.250/32", # Arthur Guo
    "47.234.195.121/32", # Arthur Guo
    "72.181.136.152/32", # Ted Howard
    "173.174.16.23/32", # Adam Ferguson
    "65.25.201.222/32", # Chandra Thummalapalli
    "76.39.238.114/32", # Chandra Thummalapalli
    "70.122.224.184/32", # Logan Romero
    "99.66.183.143/32", # Jacob Riendeau
    "40.139.1.4/32", # Logan Romero
    "68.23.26.49/32", # Brian Harrington
    "24.160.134.54/32", # Erik Gabrielsen
    "72.183.203.68/32", # Chris Johnson
    "47.185.169.246/32", # Austin Tumlinson
    "68.169.156.28/32", # David Jones
    "72.46.207.43/32", # Tom King
    "136.226.2.121/32", # Sujini Ramasamy
    "165.225.106.201/32", # Sujini Ramasamy
    "136.226.254.126/32", # Kumar Trivedi
    "165.225.124.99/32", # Kundan Kumar
    "165.225.120.77/32", # Amit Meher
    "165.225.124.96/32", #  Sameer Ahmed
    "136.226.250.86/32", # Sameer Ahmed
    "136.226.250.81/32", # Anshuk Chatterjee
    "165.225.124.96/32", # Anshuk Chatterjee
    "165.225.124.88/32", # Supriyo Dey
    "98.220.96.169/32", # Aisulu Moldabekova
    "45.22.61.101/32", # Srinivasarao Sadhanala
    "112.121.55.0/28", # mindtree ip range
    "112.121.48.1/32", # mindtree vpn
    "173.175.197.136/32", # Kim Kline
    "73.116.158.85/32", # Radhika Singu
    "3.228.39.90/32", # circleci
    "18.213.67.41/32", # circle
    "34.194.94.201/32", # circle
    "34.194.144.202/32", # circle
    "34.197.6.234/32", # circle
    "35.169.17.173/32", # circleci
    "35.174.253.146/32", # circleci
    "52.3.128.216/32", # circleci
    "52.4.195.249/32", # circleci
    "52.5.58.121/32", # circleci
    "52.21.153.129/32", # circleci
    "52.72.72.233/32", # circleci
    "54.92.235.88/32", # circleci
    "54.161.182.76/32", # circleci
    "54.164.161.41/32", # circleci
    "54.166.105.113/32", # circleci
    "54.167.72.230/32", # circleci
    "54.172.26.132/32", # circleci
    "54.205.138.102/32", # circleci
    "54.208.72.234/32", # circleci
    "54.209.115.53/32", # circleci
    "66.60.88.92/32", # Daniel Spence
    "70.114.156.90/32", # Jason Mongaras
    "76.251.167.42/32", # Mark Ehlke
    "99.245.40.69/32", # Chris Johnson
    "76.184.68.82/32", # Huy Pham
    "35.146.88.134/32", # David Thompson
    "104.129.205.15/32", # Sujini Ramasamy
    "136.226.250.97/32", # Sampoorna Manne-vpn
    "174.87.39.65/32", # David Jones
    "99.87.218.42/32", # David Hoffmann
    "108.48.190.210/32", # David Hoffmann
    "75.21.227.4/32", # Rene Siller
    "209.10.188.165/32", # RNIRVWVRAPASP01-MAXX
    "136.50.229.16/32", # Evan Cunningham
    "24.162.197.152/32", # Caitlin Connerly
    "35.146.10.69/32", # Caitlin Connerly
    "35.146.10.78/32", # Caitlin Connerly
    "68.201.59.69/32", # Caitlin Connerly
    "47.187.233.157/32", # Khrystal Mendonca
    "165.225.122.117/32", # Konuru Kumar
    "99.38.2.3/32", # Daniel Lewis
    "71.146.115.48/32", # Anastasiia Seredina
    "47.222.16.167/32", # Patricia Moturi-Taylor
    "47.188.41.163/32", # Robert Goddard
    "69.222.113.175/32", # Kiersten Magee
    "172.3.109.106/32", # Kiersten Magee 2
    "165.225.120.96/32", # Anirban Manna
    "69.234.129.252/32", # David Weise
    "3.131.147.21/32", # khalils team
    "104.3.114.75/32", # Wally Gustafson
    "209.10.188.165/32", # Corey Scott
    "187.190.185.105/32", # Luis Bolivar
    "108.209.198.29/32", # Brian Wong
    "107.200.119.243/32", # Rathnakar Moole
    "110.142.193.106/32", # Velan Packianathan
    "107.130.152.165/32", # Corey Taylor
    "99.112.184.93/32", # Noah Kirk
    "104.188.245.98/32", # Daniel Lewis
    "187.189.145.209/32", # Daniel Rodriguez
    "73.209.243.126/32", # Ashley Chan
    "47.188.178.203/32", # Daniel Lewis
    "47.189.240.137/32", # Daniel Lewis
    "131.161.56.218/32", # Raquel Sanchez
    "187.190.230.152/32", # Raquel Sanchez
    "189.203.27.224/32", # Raquel Sanchez
    "187.189.101.72/32", # Raquel Sanchez
    "187.189.33.158/32", # Raquel Sanchez
    "189.138.137.251/32", # Raquel Sanchez
    "98.207.109.130/32", # Raquel Sanchez
    "187.189.214.89/32", # Raquel Sanchez
    "138.186.29.120/32", # Raquel Sanchez
    "187.190.192.191/32", # Katia Benitez
    "68.71.68.10/32", # Jesse Bulpitt
    "47.188.179.130/32", # Daniel Lewis
    "172.59.193.228/32",
    "189.217.208.30/32", # Alejandro Escobar
    "187.188.23.0/32", # Eduardo Sanchez
    "201.163.39.44/32", # Jorge Alejandro Ruiz
    "187.190.203.174/32", # Jorge Alejandro Ruiz
    "189.216.170.47/32", # Jorge Alejandro Ruiz
    "67.183.40.119/32", # Dillon Cox
    "45.21.9.1/32", # Sid
    "172.59.229.162/32", # Greg
    "165.225.196.96/32", # Stephen Selvaraj
    "165.225.81.145/32", # Stephen Selvaraj
     "165.225.81.137/32", # Stephen Selvaraj

    "201.163.39.44/32", # Jorge Alejandro Ruiz
    "189.225.109.5/32", # Alejandro Romero
    "98.207.109.130/32", # Kellyann Cahill
    "47.188.188.250/32", # Daniel Lewis
    "98.220.81.253/32", # Ashely Chan
    "99.67.73.22/32", # Ariana Alba
    "187.190.203.174/32", # Jorge Alejandro Ruiz
    "201.124.14.238/32", # Rodrigo Bojorges
    "172.58.180.208/32", # employee
    "76.186.234.167/32", # Stefanie Goodman
    "172.58.180.208/32", 
    "172.59.196.76/32",
    "104.6.209.249/32", # employee
    "47.135.56.193/32", # David Myers
    "98.146.204.185/32", # Daniel Lewis
    "187.202.69.75/32", # Alberto Ramirez
    "189.191.213.93/32", # Alberto Ramirez
    "189.157.35.210/32", # Alberto Ramirez
    "187.190.207.121/32", # Juan Saucedo
    "76.183.140.7/32", # John Valentino
    "173.79.171.177/32", # Rohitash Laul
    "187.191.33.141/32", # Andres Figueroa
    "187.190.154.174/32", # Jose Alavez
    "187.191.39.23/32", # Alberto Picasso
    "189.203.105.237/32", # Miguel Trejo
    "68.248.193.11/32", # Austin Norryce
    "73.231.171.55/32", #Dmitrii Karataev
    "138.219.164.29/32", #Matheus
    "65.35.37.185/32", #Fernando












    ## Some ips that Seth added manually
    "207.254.8.12/32",
    "207.254.8.16/32",
    "207.254.8.17/32",
    "207.254.8.19/32",
    "207.254.8.20/32",
    "34.204.63.16/32",

  ]
}

resource "aws_waf_ipset" "whitelist" {
  name = "ecomm-allowed-ip-set"

  # dynamic below generates this from the list
  #
  # ip_set_descriptors {
  #   type = "IPV4"
  #   value = "8.8.8.8/32"
  # }

  dynamic "ip_set_descriptors" {
    for_each = toset(local.cidr_whitelist)

    content {
      type  = "IPV4"
      value = ip_set_descriptors.key
    }
  }
}

resource "aws_waf_rule" "ip_whitelist" {
  depends_on  = [aws_waf_ipset.whitelist]
  name        = "ecomm-allowed-WAFRule"
  metric_name = "ecommAllowedWAFRule"

  predicates {
    data_id = aws_waf_ipset.whitelist.id
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_waf_web_acl" "waf_acl" {
  depends_on = [
    aws_waf_ipset.whitelist,
    aws_waf_rule.ip_whitelist,
  ]
  name        = "ecomm-allowed-WebACL"
  metric_name = "ecommAllowedWebACL"

  default_action {
    type = "BLOCK"
  }

  rules {
    action {
      type = "ALLOW"
    }

    priority = 1
    rule_id  = aws_waf_rule.ip_whitelist.id
  }
}
