package com.calsoft.solidfire.service;

import java.util.List;

import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

import com.calsoft.solidfire.core.JunitInfrastructureEnabler;
import com.calsoft.solidfire.vcp.commons.exceptions.AccountServiceException;
import com.calsoft.solidfire.vcp.commons.exceptions.ClusterServiceException;
import com.calsoft.solidfire.vcp.commons.services.IAccountService;
import com.calsoft.solidfire.vcp.commons.services.IClusterService;
import com.calsoft.solidfire.vcp.commons.tos.AccountTO;
import com.calsoft.solidfire.vcp.commons.tos.ClusterTO;



public class TestAccountService  extends JunitInfrastructureEnabler{
	
	private String TEST_USERNAME = "JunitTestAccount1";
	
	private int clusterId;
	private IAccountService accountService;
	private IClusterService clusterService;
	
	@Before
	public void setup(){
		
		accountService = (IAccountService)getContext().getBean("accountService");
		clusterService = (IClusterService)getContext().getBean("clusterService");
		Assert.assertNotNull(accountService);
		Assert.assertNotNull(clusterService);
		try {
			List<ClusterTO>	cluster 	= clusterService.getDiscoveredClusters();
			Assert.assertNotNull(cluster);
			Assert.assertNotEquals(0, cluster.size());
			clusterId = cluster.get(0).getId();
		} catch (ClusterServiceException e) {
			Assert.fail("TestAccountService : setup : Failed to load cluster details : "+e.getMessage());
		}
	}
	@After
	public void teardown(){
		clusterService = null;
		accountService = null;
	}
	// Valid Case1 : Create Account JunitTestAccount1
	@Test
	public void testCreateAccount_Valid1(){
		
		AccountTO accountTO = new AccountTO();
		accountTO.setClusterId(clusterId);
		accountTO.setUsername(TEST_USERNAME);
		long accountId = 0;
		try {
			accountId = accountService.addAccount(accountTO);
			Assert.assertNotEquals(0, accountId);
			
		} catch (AccountServiceException e) {
			Assert.fail("TestAccountService : testCreateAccount_Valid1 : Failed to create user account"+e.getMessage());
		}
		finally {
			removeAccount(accountId);
		}
	}
	
	// Invalid Case1 : Try to create account with already existing name
	@Test (expected=AccountServiceException.class)
	public void testCreateAccount_InValid_ExistingName () throws AccountServiceException {
		
		long accountId = createAccount();
		
		AccountTO accountTO = new AccountTO();
		accountTO.setClusterId(clusterId);
		accountTO.setUsername(TEST_USERNAME);//set the same account name as used in createAccount api
		try {
			accountService.addAccount(accountTO);			
		} 
		finally {
			removeAccount(accountId);	
		}
	}
	
	// Invalid case2 : Try to create account with invalid cluster ID
	@Test(expected=AccountServiceException.class)
	public void testCreateAccount_InValidClusterID() throws AccountServiceException{
		AccountTO accountTO = new AccountTO();
		accountTO.setClusterId(0);
		accountTO.setUsername(TEST_USERNAME);
		accountService.addAccount(accountTO);
		 
	}
	
	//Valid Case2 : Create account JunitTestAccount2 with initiator and target key set 
	@Test
	public void testCreateAccount_Valid2(){
		
		AccountTO accountTO = new AccountTO();
		accountTO.setClusterId(clusterId);
		accountTO.setUsername("JunitTestAccount2");
		accountTO.setInitiatorSecret("initiatorSecret");
		accountTO.setTargetSecret("targetSecret");
		long accountId = 0;
		try {
			accountId = accountService.addAccount(accountTO);
			Assert.assertNotEquals(0, accountId);
		} catch (AccountServiceException e) {
			Assert.fail("TestAccountService : testCreateAccount_Valid2 : Failed to create user account"+e.getMessage());
		}finally{
			removeAccount(accountId);
		}
	}
	
	//Valid Case3 : Get account by ID
	@Test
	public void testGetAccountByID_Vaild1() {
		AccountTO account = new AccountTO();
		long accountId = createAccount();
		try {
			account = accountService.getAccountByID(clusterId, accountId);
			Assert.assertEquals(accountId, account.getAccountID());
		} catch (AccountServiceException e) {
			Assert.fail("TestAccountService : testGetAccountByID_Vaild1 : Failed to get user account by ID"+e.getMessage());
		}
		finally{
			removeAccount(accountId);
		}
	}	
	//Invalid Case3 : Get account by invalid account ID
	@Test(expected=AccountServiceException.class)
	public void testGetAccountByID_InValidAccountID() throws AccountServiceException {
		accountService.getAccountByID(clusterId, 0);
	}
	
	// Invalid case4 : Try to get account by ID with invalid cluster ID
	@Test(expected=AccountServiceException.class)
	public void testGetAccountByID_InValidClusterID() throws AccountServiceException {
		accountService.getAccountByID(0, 0);
	}
	
	//Valid Case4 : Get account by name TEST_USERNAME
	@Test
	public void testGetAccountByName_Valid1() {
		AccountTO accountTO = new AccountTO();
		long accountId = createAccount();
		
		try {
			accountTO = accountService.getAccountByName(clusterId, TEST_USERNAME);
			Assert.assertEquals(TEST_USERNAME, accountTO.getUsername());
		} catch (AccountServiceException e) {
			Assert.fail("TestAccountService : testGetAccountByName_Vaild1 : Failed to get user account by name "+e.getMessage());
		}
		finally{
			removeAccount(accountId);
		}
	}

	//Invalid Case5: Get account by invalid account name
	@Test(expected=AccountServiceException.class)
	public void testGetAccountByName_InValidAccountName() throws AccountServiceException {
		accountService.getAccountByName(clusterId, "JunitTestAccountInvalid");
	}
	
	// Invalid case6 : try to get account by name with invalid cluster ID
	@Test(expected=AccountServiceException.class)
	public void testGetAccountByName_InValidClusterID() throws AccountServiceException {
		accountService.getAccountByName(0, "JunitTestAccountInvalid");
	}
	
	//Valid Case5 : List down available accounts
	@Test
	public void testListAccounts_Valid1() {

		long accountId = createAccount();
		try {
			List<AccountTO> accounts  = accountService.listAccounts(clusterId, 0 , 1000);
			Assert.assertNotNull(accounts);
			Assert.assertNotEquals("List account returned with ZERO size", 0, accounts.size());
		} catch (AccountServiceException e) {
			Assert.fail("TestAccountService : testListAccounts_Valid1 : Failed to get user account list"+e.getMessage());
		}
		finally{
			removeAccount(accountId);
		}
	}
	
	//Invalid Case7: List accounts with invalid start and limit values
	@Test(expected=AccountServiceException.class)
	public void testListAccounts_InValidLimitValue() throws AccountServiceException {
		accountService.listAccounts(clusterId, -1, -1);
	}
	
	//Invalid case8 : Try to list AccountServiceException with invalid cluster ID
	@Test(expected=AccountServiceException.class)
	public void testListAccounts_InValidClusterID() throws AccountServiceException {
		accountService.listAccounts(0, -1, -1);
	}
	
	//Valid Case6 : Modify account status to "locked"
	@Test
	public void testModifyAccount_Valid1() { 
		long accountId 				= 	createAccount();
		AccountTO account 			= 	new AccountTO();
		String accountUpdateStatus 	= 	"locked";
		try {
			account = accountService.getAccountByID(clusterId, accountId);
			account.setClusterId(clusterId);
			account.setStatus(accountUpdateStatus);
			
			accountService.modifyAccount(account);
			
			//verify status
			account = accountService.getAccountByID(clusterId, accountId);
			Assert.assertEquals(accountUpdateStatus,account.getStatus());
			
		} catch (AccountServiceException e) {
			Assert.fail("TestAccountService : testModifyAccount_Valid1 : Failed to get account detailsfor modify account : "+e.getMessage());
		}
		finally{
			removeAccount(accountId);	
		}
	}
	//Invalid case9 : Modify account with invalid status
	@Test(expected=AccountServiceException.class)
	public void testModifyAccount_InValidStatus() throws AccountServiceException { 
		long accountID 			= 	 createAccount();
		AccountTO account 		=	 new AccountTO();
		account.setAccountID(accountID);
		account.setClusterId(clusterId);
		account.setStatus("InvalidStatus");//mark invalid status
		try {
			accountService.modifyAccount(account);
		}
		finally {
			removeAccount(accountID);
		}
	}
	
	//Invalid Case10 : Modify account with invalid clusterID
	@Test(expected=AccountServiceException.class)
	public void testModifyAccount_InValidClusterID() throws AccountServiceException { 
		long accountID 		= 	createAccount();
		AccountTO account 	= 	new AccountTO();
		account.setAccountID(accountID);
		account.setClusterId(0);
		try {
			accountService.modifyAccount(account);
		} 
		finally {
			removeAccount(accountID);
		}
	}
	
	//Valid Case7 : remove an existing account
	@Test(expected=AccountServiceException.class)
	public void testRemoveAccount_Valid1() throws AccountServiceException{
		long accountId 			= createAccount();
		accountService.removeAccount(clusterId, accountId);
		accountService.getAccountByID(clusterId, accountId); //Verify that account has deleted
	}
	
	//Invalid Case11 : remove an non-existing account
	@Test(expected=AccountServiceException.class)
	public void testRemoveAccount_InValidAccountID() throws AccountServiceException {
		accountService.removeAccount(clusterId, 0);
	}
	//Invalid Case12 : remove account with invalid cluster id
	@Test(expected=AccountServiceException.class)
	public void testRemoveAccount_InValidClusterID() throws AccountServiceException {
		accountService.removeAccount(0, 0);
	}
	
	private long createAccount() {
		
		AccountTO accountTo = new AccountTO();
		accountTo.setClusterId(clusterId);
		accountTo.setUsername(TEST_USERNAME);
		long accountID = 0;
		try {
			accountID = accountService.addAccount(accountTo );
		} catch (AccountServiceException e) {
			Assert.fail("TestAccountService : createAccount : Failed to create account"+e.getMessage());
		}
		return accountID;
	}
	
	
	private void removeAccount(long accountId) {
		try {
			if(accountId > 0 )
				accountService.removeAccount(clusterId, accountId);
		} catch (AccountServiceException e) {
			Assert.fail("TestAccountService : removeAccount : Failed to remove account"+e.getMessage());
		}
	}
}
