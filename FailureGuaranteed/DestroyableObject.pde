public abstract class DestroyableObject {
  protected boolean flagged;
  
  protected DestroyableObject() {
    flagged = false;
  }
  
  public void flag() {
    flagged = true; 
  }
  
  public boolean isFlagged() {
    return flagged;
  }
}
