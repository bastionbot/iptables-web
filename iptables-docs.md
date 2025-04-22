## Basic Concepts

### 1. What is a firewall?

In a computer, a firewall is a network security system that monitors and controls incoming and outgoing network traffic based on predetermined security rules. All network communications flowing into and out of the computer must pass through this firewall. The firewall scans the network communications flowing through it, which can filter out some attacks to prevent them from being executed on the target computer. The firewall can also close unused ports. It can also prohibit outgoing communications from specific ports and block Trojan horses. Finally, it can prohibit access from special sites, thereby preventing all communications from unknown intruders.

#### 1.1 Firewalls are divided into software firewalls and hardware firewalls, their advantages and disadvantages:

**Hardware firewall**: It has specially designed hardware and chips, high performance and high cost (of course, hardware firewalls also have software, but some functions are implemented by hardware, so hardware firewalls are actually hardware + software);

**Software firewall**: A firewall whose application software processing logic runs on a general hardware platform, with lower performance and lower cost than hardware firewalls.

#### 1.2 Relationship between Netfilter and iptables

Netfilter is a Linux 2.4 kernel firewall framework proposed by Rusty Russell. The framework is concise and flexible, and can implement many functions in security policy applications, such as packet filtering, packet processing, address masquerading, transparent proxy, dynamic Network Address Translation (NAT), and filtering based on user and Media Access Control (MAC) addresses and state-based filtering, packet rate limiting, etc. These rules of Iptables/Netfilter can be flexibly combined to form a lot of functions and cover all aspects, all thanks to its excellent design ideas.

Netfilter is a packet processing module inside the Linux operating system core layer. It has the following functions:

- Network Address Translation

- Packet content modification

- And the firewall function of packet filtering

Five hook points (Hook Point, which can be understood as callback function points, will actively call our functions when the packets arrive at these locations, giving us the opportunity to change their direction and content when the packets are routed) are set in the Netfilter platform. These five hook points are `PRE_ROUTING`, `INPUT`, `OUTPUT`, `FORWARD`, and `POST_ROUTING`.

The rules set by Netfilter are stored in the kernel space, and **iptables is an application layer application that modifies XXtables (Netfilter configuration table) stored in the kernel space through the interface released by Netfilter**. This XXtables consists of tables, chains, and rules. Iptables is responsible for modifying this rule file at the application layer. Similar applications include firewalld (CentOS7 default firewall).

So the real firewall in Linux is Netfilter, but since it is operated through application layer programs such as iptables or firewalld, we generally call iptables or firewalld the Linux firewall.

**Note**: The iptables mentioned above are all for IPv4. If IPv6, ip6tables should be used, and the usage should be the same as iptables.

Note: When the Linux system is running, the memory is divided into kernel space and user space. The kernel space is the space where the Linux kernel code runs. It can directly call system resources. The user space refers to the space where user programs run. Programs in user space cannot directly call system resources and must use the interface "system call" provided by the kernel.

### 2. The concept of chain

After iptables is enabled, data packets will go through 5 checkpoints from entering the server to exiting, namely Prerouting (before routing), Input (input), Outpu (output), Forward (forwarding), and Postrouting (after routing):

![Data flow](https://doc.xujianqq.com.cn/doc/03/ae2ec6f73b5dd9849c93dfc074cac997.jpg)

There are multiple rules in each checkpoint, and data packets must match these rules one by one in order. These rules are strung together like a chain, so we call these checkpoints `chains`:

![chain](https://doc.xujianqq.com.cn/doc/03/e3ffc9afdb8cd8bd450ed917e3fe50e3.png)

- **INPUT chain**: When receiving a data packet from the firewall's local address (inbound), the rules in this chain are applied;

- **OUTPUT chain**: When the firewall sends a data packet outward (outbound), the rules in this chain are applied;

- **FORWARD chain**: When receiving a data packet that needs to be sent to other addresses through the firewall (forwarding), the rules in this chain are applied;

- **PREROUTING chain**: Before routing the data packet, the rules in this chain are applied, such as DNAT;

- **POSTROUTING chain**: After routing the data packet, the rules in this chain are applied, such as SNAT.

Among them, the INPUT and OUTPUT chains are more used in "host firewalls", that is, they are mainly for security control of data entering and leaving the server; while the FORWARD, PREROUTING, and POSTROUTING chains are more used in "network firewalls", especially when the firewall server is used as a gateway.

### 3. Concept of table

Although there are multiple rules on each chain, some rules have similar functions. Multiple rules with the same function are combined to form a table. Iptables provides four types of tables:

- **filter table**: mainly used to filter data packets, and decide whether to release the data packet according to specific rules (such as DROP, ACCEPT, REJECT, LOG). The so-called firewall actually basically refers to the filtering rules on this table, corresponding to the kernel module iptables_filter;

- **nat table**: network address translation, network address translation function, mainly used to modify the IP address, port number and other information of the data packet (network address translation, such as SNAT, DNAT, MASQUERADE, REDIRECT). Packets belonging to a flow (due to the size limit of the packet, the data may be divided into multiple packets) will only pass through this table once. If the first packet is allowed to do NAT or Masqueraded, then the remaining packets will automatically do the same operation, that is, the remaining packets will not pass through this table again. Corresponding to kernel module iptables_nat;

- **mangle table**: disassembles the message, makes modifications, and re-encapsulates it. It is mainly used to modify the TOS (Type Of Service) and TTL (Time To Live) of the data packet and set the Mark mark for the data packet to achieve QoS (Quality Of Service) adjustment and policy routing applications. Since it requires corresponding routing equipment support, it is not widely used. Corresponding to kernel module iptables_mangle;

- **raw table**: It is a new table added to iptables since version 1.2.9. It is mainly used to determine whether the data packet is processed by the state tracking mechanism. When matching data packets, the rules of the raw table take precedence over other tables. Corresponding to kernel module iptables_raw.

**The firewall rules we finally define will be added to one of these four tables. **

### 4. Table chain relationship

Among the 5 chains (i.e. 5 levels), not every chain can apply all types of tables. In fact, except for the Ouptput chain, which can have four tables at the same time, other chains only have two or three tables:

![table](https://doc.xujianqq.com.cn/doc/03/55afd069e4f1ba01d87cee0b9322c6c7.png)

In fact, from the above figure, we can see that no matter which chain, the raw table is always above the mangle table, and the mangle table is always above the nat table, and the nat table is always above the filter table, which shows that there is a matching order between the tables.

As mentioned above, data packets must match the rules on each chain one by one in order, but in fact, the rules of the same category (that is, belonging to the same table) are placed together, and the rules of different categories are not placed crosswise. According to the above rules, the order in which the tables on each chain are matched is: `raw → mangle → nat → filter`.

The firewall rules we finally define will be added to one of these four tables, so our actual operation is to operate on the `table`, so let's talk about which chains each table can be used for:

![image-20220403175755180](https://doc.xujianqq.com.cn/doc/03/image-20220403175755180.png)

In summary, the process of data packets passing through the firewall can be summarized as follows:

![protocol](https://doc.xujianqq.com.cn/doc/03/ac586d71025972c3c200ca6bc96917c5.png)

### 5. The concept of rules

iptables rules mainly include `conditions & actions`, that is, what actions are taken after matching what conditions (rules) are met.

#### 5.1 Matching conditions

```shell
-i --in-interface Network interface name Specifies the network interface from which the data packet enters,
-o --out-interface Network interface name Specifies the network interface from which the data packet outputs
-p ---proto Protocol type Specifies the protocol that the data packet matches, such as TCP, UDP, and ICMP, etc.
-s --source Source address or subnet Specifies the source address that the data packet matches
-sport Source port number Specifies the source port number that the data packet matches
-dport Destination port number Specifies the destination port number that the data packet matches
-m --match Matching module Specifies the filtering module used by the data packet rule
```

#### 5.2 Processing actions

In addition to `ACCEPT, REJECT, DROP, REDIRECT, MASQUERADE`, iptables processing actions also include `LOG, ULOG, DNAT, RETURN, TOS, SNAT, MIRROR, QUEUE, TTL, MARK`, etc. We will only explain the most commonly used actions:

- ACCEPT allows the data packet to pass

- REJECT blocks the data packet and returns a data packet to notify the other party. There are several options for the data packet that can be returned: ICMP port-unreachable, ICMP echo-reply or tcp-reset (this data packet will ask the other party to close the connection). After this processing action, no other rules will be compared and the filtering process will be directly interrupted. Examples are as follows:

```shell
$ iptables -A INPUT -p TCP --dport 22 -j REJECT --reject-with ICMP echo-reply
```

- DROP discards the data packet and does not process it. After this processing action, no other rules will be compared and the filtering process will be directly interrupted.

- REDIRECT redirects the packet to another port (PNAT). After this processing action, other rules will continue to be compared. This function can be used to implement transparent proxy or to protect web servers. For example:

```shell
$ iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT--to-ports 8081
```

- MASQUERADE rewrites the source IP of the packet to the IP of the firewall. You can specify the port range. After completing this processing action, it will directly jump to the next rule chain (mangle: postrouting). This function is slightly different from SNAT. When performing IP masquerading, you do not need to specify which IP to masquerade as. The IP will be read directly from the network card. When using a dial-up connection, the IP is usually assigned by the ISP's DHCP server. At this time, MASQUERADE is particularly useful. The example is as follows:

```shell
$ iptables -t nat -A POSTROUTING -p TCP -j MASQUERADE --to-ports 21000-31000
```

- LOG records the packet information in /var/log. For detailed location, please refer to the /etc/syslog.conf configuration file. After completing this processing action, other rules will be compared. For example:

```shell