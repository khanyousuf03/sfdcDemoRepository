trigger contactDuplicatePreventer on Contact
                               (before insert, before update) {

    Map<String, Contact> contactMap = new Map<String, Contact>();
    for (Contact Contact : System.Trigger.new) {
		
        // Make sure we don't treat an email address that  
        // isn't changing during an update as a duplicate.  
    
        if ((Contact.Email != null) &&
                (System.Trigger.isInsert ||
                (Contact.Email != 
                    System.Trigger.oldMap.get(Contact.Id).Email))) {
		
            // Make sure another new Contact isn't also a duplicate  
    
            if (contactMap.containsKey(Contact.Email)) {
                Contact.Email.addError('Another new Contact has the '
                                    + 'same email address.');
            } else {
                contactMap.put(Contact.Email, Contact);
            }
       }
    }
	
    // Using a single database query, find all the Contacts in  
    
    // the database that have the same email address as any  
    
    // of the Contacts being inserted or updated.  
    
    for (Contact contact : [SELECT Email FROM Contact
                      WHERE Email IN :contactMap.KeySet()]) {
        Contact newContact = contactMap.get(Contact.Email);
        newContact.Email.addError('duplicate email found ');
    }
}