import sys
sys.path.append("..")
import lib.libsf as libsf
#import logging
#libsf.mylog.console.setLevel(logging.DEBUG)

print "CustomerName,ClusterName,NodeType,NodeCount,BSDriveCount,AveNodeCapacity,MaxNodeUsed,TotalClusterCapacity,TotalUsedSpace"

result = libsf.CallApiMethod("remote-support.solidfire.com", None, None, "LoginUser", {"username" : "carl.seelye@solidfire.com", "password" : "solidfire"}, ApiVersion=1.0, UseCookies=True)
cluster_list = libsf.CallApiMethod("remote-support.solidfire.com", None, None, "ListActiveClusters", {}, ApiVersion=1.0, UseCookies=True)

for cluster in cluster_list["clusters"]:
    if cluster["clusterDown"] : continue
    node_list = libsf.CallApiMethod("remote-support.solidfire.com", None, None, "ListActiveNodes", {"clusterID" : cluster["clusterID"]}, ApiVersion=1.0, UseCookies=True)
    node_count = len(node_list["nodes"])
    ave_node_capacity = cluster["maxUsedSpace"] / node_count
    ave_node_used = cluster["usedSpace"] / node_count

    drive_list = libsf.CallApiMethod("remote-support.solidfire.com", None, None, "ListDrives", {"clusterID" : cluster["clusterID"]}, ApiVersion=1.0, UseCookies=True)
    bs_count = 0
    for drive in drive_list["drives"]:
        if drive["status"] != "active": continue
        if drive["type"] != "block": continue
        if drive["capacity"] / 1000 / 1000 / 1000 == 300:
            model = "3010"
        else:
            model = "6010"
        bs_count += 1

    # Find out the total used space on the fullest node
    #stats = CallApi("GetCompleteStats", {"clusterID" : cluster["clusterID"]})
    #max_node_used = 0
    #for cluster_name in stats:
        #for node in stats[cluster_name]["nodes"]:
            #current_node_used = 0
            #for service in stats[cluster_name]["nodes"][node]:
                #if 'block' not in service: continue
                #used = stats[cluster_name]["nodes"][node][service]['activeDiskBytes'][0]
                #current_node_used += used
            #if current_node_used > max_node_used:
                #max_node_used = current_node_used



    print cluster["customerName"] + "," + cluster["clusterName"] + "," + model + "," + str(node_count) + "," + str(bs_count) + "," + str(ave_node_capacity) + "," + str(ave_node_used) + "," + str(cluster["maxUsedSpace"]) + "," + str(cluster["usedSpace"])
