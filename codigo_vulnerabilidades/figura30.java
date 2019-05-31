

class SafeClass
{
  private ArrayList<int> a;

  public SafeClass()
  {
    this.a = new ArrayList<int>();
  }

  public void addInt(int n)
  {
    this.a.add(n);
  }

  public void massOperation()
  {
    for(int i = 0; i < this.a.size();i++)
      this.a.set(i,this.a.get(i)+1);
  }
}
