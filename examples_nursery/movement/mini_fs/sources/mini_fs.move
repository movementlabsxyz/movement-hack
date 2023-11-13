module MiniFs {

  // Struct representing a file entry in the MiniFs contract
  struct FileEntry {
    key: vector<u8>,
    value: vector<u8>,
  }

  // MiniFs struct representing the contract state
  struct MiniFs {
    files: vector<FileEntry>,
  }

  // Hash function to compute the initial index based on the key
  public fun hash(key: vector<u8>, size: u8): u8 {
    let mut hash: u8 = 0;
    for byte in key {
      hash = (hash.wrapping_mul(31)).wrapping_add(byte);
    }
    hash % size
  }

  // Initialization function for the MiniFs contract
  public fun init(size: u8): MiniFs {
    let files = Vector::create();
    Vector::resize(&mut files, size, FileEntry{ key: vector<u8>(0), value: vector<u8>(0) });
    MiniFs {
      files: files,
    }
  }

  // Put function to add or update a file in the filesystem
  public fun put(key: vector<u8>, value: vector<u8>) {
    let self = &mut MiniFs::borrow_global_mut();
    let size = Vector::length(&self.files);
    let initial_index = hash(key, size);
    let mut index = initial_index;
    let mut count = 0;
    while count < size && self.files[index as usize].key != vector<u8>(0) {
      if self.files[index as usize].key == key {
        self.files[index as usize].value = value;
        return; // Update the value and return
      }
      index = (index + 1) % size;
      count += 1;
    }
    
    // If the loop exits, it means an entry with the given key was not found
    if count >= size {
      assert(false, 99); // Maximum number of files reached
    }
    
    // Add a new entry since the key was not found
    self.files[index as usize].key = key;
    self.files[index as usize].value = value;
  }

  // Get function to retrieve the value of a file by its key
  public fun get(key: vector<u8>): vector<u8> {
    let self = &MiniFs::borrow_global();
    let size = Vector::length(&self.files);
    let initial_index = hash(key, size);
    let mut index = initial_index;
    let mut count = 0;
    while count < size && self.files[index as usize].key != vector<u8>(0) {
      if self.files[index as usize].key == key {
        return self.files[index as usize].value.clone(); // Return the value
      }
      index = (index + 1) % size;
      count += 1;
    }
    vector<u8>(0) // File not found, return an empty vector
  }

  // Delete function to remove a file from the filesystem
  public fun delete(key: vector<u8>) {
    let self = &mut MiniFs::borrow_global_mut();
    let size = Vector::length(&self.files);
    let initial_index = hash(key, size);
    let mut index = initial_index;
    let mut count = 0;
    while count < size && self.files[index as usize].key != vector<u8>(0) {
      if self.files[index as usize].key == key {
        self.files[index as usize].key = vector<u8>(0);
        self.files[index as usize].value = vector<u8>(0);
        return; // Delete the file and return
      }
      index = (index + 1) % size;
      count += 1;
    }
  }
}
