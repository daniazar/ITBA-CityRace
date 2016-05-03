using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;

[ExecuteInEditMode()]

public class PathNodeObjects 
{
	public Vector3 position;
	public float width;
}

public struct TerrainPathCell
{
	public Vector3 position;
	public bool isAdded;
};

public class AttachedPathScript : MonoBehaviour 
{
	// Array of terrain cells for convenience 
	public TerrainPathCell[] terrainCells;
	
	public bool isRoad = true;
	public bool isFinalized;
	
	public PathNodeObjects[] nodeObjects;
	public Vector3[] nodeObjectVerts; // keeps vertice positions for handles
	
	public GameObject pathMesh;
	public MeshCollider pathCollider;
	
	// central terrian cells
	public ArrayList pathCells;
	public ArrayList totalPathVerts;
	public ArrayList innerPathVerts;
	
	// GUI variables
	public int pathWidth = 8;
	public bool pathFlat;
	public int pathSmooth =8;
	public GameObject bordr;
	
	public MeshFilter bordrMesh ;
	public MeshCollider bordrCol ;

	public int elipticNodes = 18;
	public float elipticRadiusA  = 237.408f ;
	public float elipticRadiusB = 130.242f;	
	public int MaxRandomA = 70;
	public int MaxRandomB = 100;
	System.Random rand;
	private bool flatten = true;
	
	public static int randomSeed = 0;
	
	private Vector3[] newVertices;
	
	public GameObject waypoint;
	public string WayPointTag = "waypoint";
	
	
	public static GameObject actualWaypoint;
	
	
	public static GameObject[] childs;
	
	
	
	//This Funtion is called when a character pass a chekpoint	
	public static void VerifyLocation(GameObject a){
/*		bool mark = true;
		CheckPoint p = ((CheckPoint)a.GetComponent(typeof(CheckPoint)));
	if(!p.pass)
	{	
		foreach(GameObject c in childs)
		{
			if(c.name.Length <=  a.name.Length && c.name <= a.name)
			{
				if( ((CheckPoint)c.GetComponent(typeof(CheckPoint))).pass)
				{
					;
				}else
				{
					mark = false;
					break;
				}
			}
		}
	}	
		if(mark)
			p.pass = true;
		Debug.Log(p.pass);*/	
	}
		
		
	void Awake(){
		GenerateEasyElipicPath();
		FinalizePath();
		pathMesh.renderer.enabled = true;
		
	}
	
	//Generate a complex path
	public void GenerateElipicPath()
	{

		rand = new System.Random(randomSeed);
		ResetPath();
		float theta = 0.0f;
			float x = (float)elipticRadiusA * ((float)Math.Cos(theta));
			float z = (float)elipticRadiusB * ((float)Math.Sin(theta));
			
		for(int i=0; i <= elipticNodes ; i ++){
			theta = (float) 2* ((float)Math.PI) * i / elipticNodes;
			
				x = (float)elipticRadiusA * (float)rand.Next(MaxRandomA) * ((float)Math.Cos(theta));
				z = (float)elipticRadiusB * ((float)Math.Sin(theta));
			AddPathNode(new Vector3(x , 0 , z));
			
		}
		
		for(int i=0; i <= 3 ; i ++){
			
			AddPathNode(new Vector3(nodeObjects[i].position.x, nodeObjects[i].position.y, nodeObjects[i].position.z));
			
		}
		CreatePath(pathSmooth, false);
	}
	
	//Generate an easy path
	public void GenerateEasyElipicPath()
	{
		//Debug.Log("Random " + randomSeed);
		rand = new System.Random(randomSeed);
		ResetPath();
		float theta = 0.0f;
			float x = (float)elipticRadiusA * ((float)Math.Cos(theta));
			float z = (float)elipticRadiusB * ((float)Math.Sin(theta));
			
		for(int i=0; i <= elipticNodes ; i ++){
			theta = (float) 2* ((float)Math.PI) * i / elipticNodes;
			
				x = ((float)elipticRadiusA + (float)rand.Next(MaxRandomA)) * ((float)Math.Cos(theta));
				z = ((float)elipticRadiusB + (float)rand.Next(MaxRandomB)) * ((float)Math.Sin(theta));
			AddPathNode(new Vector3(x , 0 , z));
			
		}
		
		//for(int i=0; i <= 1 ; i ++){
			
		//	AddPathNode(new Vector3(nodeObjects[i].position.x, nodeObjects[i].position.y, nodeObjects[i].position.z));
			
		//}
		
		
		
		CreatePath(pathSmooth, false);

	}
	
	//Generate way points that can be used for checkpoints or IA.
	public void GenerateWayPoints(){
		childs= new GameObject[elipticNodes + 1];
			for(int i=0; i <= elipticNodes ; i ++){
				GameObject b = (GameObject) GameObject.Instantiate(waypoint,new Vector3(nodeObjects[i].position.x, nodeObjects[i].position.y, nodeObjects[i].position.z), Quaternion.identity);
				b.name = "WayPoint_" + i;
				b.tag = WayPointTag;
				b.transform.parent = transform;
				childs[i]= b;
				if(i == 0){
				CheckPoint ch = b.GetComponent<CheckPoint>();
				ch.final = true;
				}

			}	
			
			actualWaypoint =  childs[0];
		}
	
	
	//Generates a new simple path
	public void NewPath()
	{
		ResetPath();
		nodeObjects = new PathNodeObjects[0];
		pathCollider = (MeshCollider)pathMesh.AddComponent(typeof(MeshCollider));
	    bordrMesh = (MeshFilter)bordr.GetComponent(typeof(MeshFilter));
	    bordrCol = (MeshCollider)bordr.GetComponent(typeof(MeshCollider));
	    
	    
	    		CreatePath(pathSmooth, false);

	}
	
	
	//Resets variables to create a new mesh.
	public void ResetPath()
	{
		//Destorys Waypoints
		if(childs != null){
			foreach(GameObject c in childs){
				DestroyImmediate(c);
			}
		}
		childs = null;
		nodeObjects = new PathNodeObjects[0];
		CreatePath(pathSmooth, false);
		MeshFilter meshFilter = (MeshFilter)pathMesh.GetComponent(typeof(MeshFilter));
		meshFilter.sharedMesh = new Mesh();		
		pathCollider.sharedMesh = meshFilter.sharedMesh;
	}
	
	//Adds a node to the mesh.
	public void AddPathNode(Vector3  pathNode)
	{
		TerrainPathCell pathNodeCell = new TerrainPathCell();
		pathNodeCell.position.x = pathNode.x;
		pathNodeCell.position.y = pathNode.y;
		pathNodeCell.position.z = pathNode.z;
		CreatePathNode(pathNodeCell);
	}
		
	//Adds a node.
	public void CreatePathNode(TerrainPathCell nodeCell)
	{
		Vector3 pathPosition = new Vector3(nodeCell.position.x, nodeCell.position.y , nodeCell.position.z);
		AddNode(pathPosition, pathWidth);
	}
	
	//adds a node.
	public void AddNode(Vector3 position, float width)
	{
		PathNodeObjects newPathNodeObject = new PathNodeObjects();
		int nNodes;
		if(nodeObjects == null)
		{
			nodeObjects = new PathNodeObjects[0];
			nNodes = 1;
			newPathNodeObject.position = position;
		}
		else
		{
			nNodes = nodeObjects.Length + 1;
			newPathNodeObject.position = position;
		}
		PathNodeObjects[] newNodeObjects = new PathNodeObjects[nNodes];
		newPathNodeObject.width = width;
		int n = newNodeObjects.Length;
		
		for (int i = 0; i < n; i++) 
		{
			if (i != n - 1) 
			{
				newNodeObjects[i] = nodeObjects[i];
			}
			else 
			{
				newNodeObjects[i] = newPathNodeObject;
			}
		}		
		nodeObjects = newNodeObjects;
	}
	
	//generates the mesh and collider.
	public void CreatePath(int smoothingLevel, bool road)
	{
		MeshFilter meshFilter = (MeshFilter)pathMesh.GetComponent(typeof(MeshFilter));
		
		if(meshFilter == null)
			return;
		
		Mesh newMesh = meshFilter.sharedMesh;		
		pathCells = new ArrayList();
	 
		if (newMesh == null) 
		{
			newMesh = new Mesh();
			newMesh.name = "Generated Path Mesh";
			meshFilter.sharedMesh = newMesh;
		} 
	  
		else 
			newMesh.Clear();

		
		if (nodeObjects == null || nodeObjects.Length < 2) 
		{
			return;
		}
		
		int n = nodeObjects.Length;

		int verticesPerNode = 2 * (smoothingLevel + 1) * 2;
		int trianglesPerNode = 6 * (smoothingLevel + 1);
		Vector2[] uvs = new Vector2[(verticesPerNode * (n - 1))];
		Vector3[] newVertices = new Vector3[(verticesPerNode * (n - 1))];
		int[] newTriangles = new int[(trianglesPerNode * (n - 1))];
		nodeObjectVerts = new Vector3[(verticesPerNode * (n - 1))];
		int nextVertex  = 0;
		int nextTriangle = 0;
		int nextUV = 0;
		
		// variables for splines and perpendicular extruded points
		float[] cubicX = new float[n];
		float[] cubicY = new float[n];
		float[] cubicZ = new float[n];
		Vector3[] g1 = new Vector3[smoothingLevel+1];
		Vector3[] g2 = new Vector3[smoothingLevel+1];
		Vector3[] g3 = new Vector3[smoothingLevel+1];
		Vector3 oldG2 = new Vector3();
		Vector3 extrudedPointL = new Vector3();
		Vector3 extrudedPointR = new Vector3();
		
		for(int i = 0; i < n; i++)
		{
			cubicX[i] = nodeObjects[i].position.x;
			cubicY[i] = nodeObjects[i].position.y;
			cubicZ[i] = nodeObjects[i].position.z;
		}
		
		for (int i = 0; i < n; i++) 
		{
			g1 = new Vector3[smoothingLevel+1];
			g2 = new Vector3[smoothingLevel+1];
			g3 = new Vector3[smoothingLevel+1];
			
			extrudedPointL = new Vector3();
			extrudedPointR = new Vector3();
			
			if (i == 0)
			{
				newVertices[nextVertex] = nodeObjects[0].position;
				nextVertex++;
				uvs[0] = new Vector2(0f, 1f);
				nextUV++;
				newVertices[nextVertex] = nodeObjects[0].position;
				nextVertex++;
				uvs[1] = new Vector2(1f, 1f);
				nextUV++;
				
				continue;
			}
			
			float _widthAtNode = pathWidth;		
			
			// Interpolate points along the path using splines for direction and bezier curves for heights
			for (int j = 0; j < smoothingLevel + 1; j++) 
			{
				// clone the vertex for uvs
				if(i == 1)
				{
					if(j != 0)
					{
						newVertices[nextVertex] = newVertices[nextVertex-2];
						nextVertex++;
						
						newVertices[nextVertex] = newVertices[nextVertex-2];
						nextVertex++;
						
						uvs[nextUV] = new Vector2(0f, 1f);
						nextUV++;
						uvs[nextUV] = new Vector2(1f, 1f);
						nextUV++;
					}
					
					else
						oldG2 = nodeObjects[0].position;
				}
				
				else
				{
					newVertices[nextVertex] = newVertices[nextVertex-2];
					nextVertex++;
					
					newVertices[nextVertex] =newVertices[nextVertex-2];
					nextVertex++;
					
					uvs[nextUV] = new Vector2(0f, 1f);
					nextUV++;
					uvs[nextUV] = new Vector2(1f, 1f);
					nextUV++;
				}
				
				float u = (float)j/(float)(smoothingLevel+1f);
				
				Cubic[] X = calcNaturalCubic(n-1, cubicX);
				Cubic[] Z = calcNaturalCubic(n-1, cubicZ);
				
				Vector3 tweenPoint = new Vector3(X[i-1].eval(u), 0f, Z[i-1].eval(u));
				
				// Add the current tweenpoint as a path cell
				TerrainPathCell tC = new TerrainPathCell();
				tC.position.x = tweenPoint.x;
				tC.position.y = tweenPoint.y;
				tC.position.z = tweenPoint.z;
				pathCells.Add(tC);
				
				// update tweened points
				g2[j] = tweenPoint;
				g1[j] = oldG2;
				g3[j] = g2[j] - g1[j];
				oldG2 = g2[j];
				
				// Create perpendicular points for vertices
				extrudedPointL = new Vector3(-g3[j].z, 0, g3[j].x);
				extrudedPointR = new Vector3(g3[j].z, 0, -g3[j].x);
				extrudedPointL.Normalize();
				extrudedPointR.Normalize();
				extrudedPointL *= _widthAtNode;
				extrudedPointR *= _widthAtNode;
				

				// create vertices at the perpendicular points
				newVertices[nextVertex] = tweenPoint + extrudedPointR;
				nodeObjectVerts[nextVertex] = newVertices[nextVertex];
				nextVertex++;
				
				newVertices[nextVertex] = tweenPoint + extrudedPointL;
				nodeObjectVerts[nextVertex] = newVertices[nextVertex];
				nextVertex++;

				uvs[nextUV] = new Vector2(0f, 0f);
				nextUV++;
				uvs[nextUV] = new Vector2(1f, 0f);
				nextUV++;
				
				// flatten mesh
				if(flatten && !road)
				{
					if(newVertices[nextVertex-1].y < (newVertices[nextVertex-2].y-0.0f))
					{
						extrudedPointL *= 1.5f;
						extrudedPointR *= 1.2f;
						newVertices[nextVertex-1] = tweenPoint + extrudedPointL;
						newVertices[nextVertex-2] = tweenPoint + extrudedPointR;
						
						newVertices[nextVertex-1].y = newVertices[nextVertex-2].y;
					}
				
					else if(newVertices[nextVertex-1].y > (newVertices[nextVertex-2].y-0.0f))
					{
						extrudedPointR *= 1.5f;
						extrudedPointL *= 1.2f;
						newVertices[nextVertex-2] = tweenPoint + extrudedPointR;
						newVertices[nextVertex-1] = tweenPoint + extrudedPointL;
						
						newVertices[nextVertex-2].y = newVertices[nextVertex-1].y;		
					}
				}

				// Create triangles...
				newTriangles[nextTriangle] = (verticesPerNode * (i - 1)) + (4 * j); // 0
				nextTriangle++;
				newTriangles[nextTriangle] = (verticesPerNode * (i - 1)) + (4 * j) + 1; // 1
				nextTriangle++;
				newTriangles[nextTriangle] = (verticesPerNode * (i - 1)) + (4 * j) + 2; // 2
				nextTriangle++;
				newTriangles[nextTriangle] = (verticesPerNode * (i - 1)) + (4 * j) + 1; // 1
				nextTriangle++;
				newTriangles[nextTriangle] = (verticesPerNode * (i - 1)) + (4 * j) + 3; // 3
				nextTriangle++;
				newTriangles[nextTriangle] = (verticesPerNode * (i - 1)) + (4 * j) + 2; // 2
				nextTriangle++;
			}
		}
		
	
		extrudedPointL = new Vector3(-g3[0].z, 0, g3[0].x);
		extrudedPointR = new Vector3(g3[0].z, 0, -g3[0].x);
		
		extrudedPointL.Normalize();
		extrudedPointR.Normalize();
		extrudedPointL *= nodeObjects[0].width;
		extrudedPointR *= nodeObjects[0].width;
		
		newVertices[0] = nodeObjects[0].position + extrudedPointR;
		newVertices[1] = nodeObjects[0].position + extrudedPointL;
		
		
		newMesh.vertices = newVertices;
		newMesh.triangles = newTriangles;
		
		newMesh.uv =  uvs;
		
		Vector3[] myNormals = new Vector3[newMesh.vertexCount];
		for(int p = 0; p < newMesh.vertexCount; p++)
		{
			myNormals[p] = Vector3.up;
		}

		newMesh.normals = myNormals;
		
		TangentSolver(newMesh);

		newMesh.RecalculateNormals();
		pathCollider.sharedMesh = meshFilter.sharedMesh;
		pathCollider.smoothSphereCollisions = true;
		
		// we don't want to see the mesh
		if(!isRoad)
			pathMesh.renderer.enabled = false;
		else
			pathMesh.renderer.enabled = true;
		
		transform.localScale = new Vector3(1,1,1);
		/*
		// from here we create a sidebar for the road.
		bordrMesh.sharedMesh = new Mesh();
		Mesh bMesh = bordrMesh.sharedMesh;	
		Vector3[] borVertices = new Vector3[(verticesPerNode * (n - 1) *2)];	
		
		for(int i = 1; i < verticesPerNode * (n - 5); i+=2)
        {    
        	
           		borVertices[i] = new Vector3(newVertices[i].x, newVertices[i].y + 4, newVertices[i].z);
			
				borVertices[i+1] = new Vector3(newVertices[i-1].x, newVertices[i-1].y, newVertices[i-1].z);
			    
        }
    
    		
		int[] borTriangles = new int[(trianglesPerNode * (n - 1))];
		int limite= (trianglesPerNode * (n - 1)); 
		for(int i = 0; i < limite; i++)
        {    	
           borTriangles[i] = newTriangles[i];
                  
        }	
        bMesh.vertices = newVertices;
		bMesh.triangles = newTriangles;
	    bMesh.uv =  uvs;
     	
        Vector3[] mNormals = new Vector3[bMesh.vertexCount];
		for(int p = 0; p < bMesh.vertexCount; p++)
		{
			mNormals[p] = Vector3.up;
		}

		bMesh.normals = mNormals;
		
		TangentSolver(bMesh);

		bMesh.RecalculateNormals();
		bordrCol.sharedMesh = bordrMesh.sharedMesh;
		bordrCol.smoothSphereCollisions = true;
		*/
		
        
		
		//Destorys Waypoints
		if(childs != null){
			foreach(GameObject c in childs){
				DestroyImmediate(c);
			}
		}
		childs = null;
		
		GenerateWayPoints();

    }
	
	//finaliize the mesh if there were some things left to do. like make the mesh visible.
	public void FinalizePath()
	{
		CreatePath(pathSmooth, true);
		isFinalized = true;
	}
		
	
	
	
	// From here we use this functions to calculate the path betwen the nodes.
	public void TangentSolver(Mesh theMesh)
    {
        int vertexCount = theMesh.vertexCount;
        Vector3[] vertices = theMesh.vertices;
        Vector3[] normals = theMesh.normals;
        Vector2[] texcoords = theMesh.uv;
        int[] triangles = theMesh.triangles;
        int triangleCount = triangles.Length/3;
        Vector4[] tangents = new Vector4[vertexCount];
        Vector3[] tan1 = new Vector3[vertexCount];
        Vector3[] tan2 = new Vector3[vertexCount];
        int tri = 0;
		
		int i1, i2, i3;
		Vector3 v1, v2, v3, w1, w2, w3, sdir, tdir;
		float x1, x2, y1, y2, z1, z2, s1, s2, t1, t2, r;
        for (int i = 0; i < (triangleCount); i++)
        {
            i1 = triangles[tri];
            i2 = triangles[tri+1];
            i3 = triangles[tri+2];

            v1 = vertices[i1];
            v2 = vertices[i2];
            v3 = vertices[i3];

            w1 = texcoords[i1];
            w2 = texcoords[i2];
            w3 = texcoords[i3];

            x1 = v2.x - v1.x;
            x2 = v3.x - v1.x;
            y1 = v2.y - v1.y;
            y2 = v3.y - v1.y;
            z1 = v2.z - v1.z;
            z2 = v3.z - v1.z;

            s1 = w2.x - w1.x;
            s2 = w3.x - w1.x;
            t1 = w2.y - w1.y;
            t2 = w3.y - w1.y;

            r = 1.0f / (s1 * t2 - s2 * t1);
            sdir = new Vector3((t2 * x1 - t1 * x2) * r, (t2 * y1 - t1 * y2) * r, (t2 * z1 - t1 * z2) * r);
            tdir = new Vector3((s1 * x2 - s2 * x1) * r, (s1 * y2 - s2 * y1) * r, (s1 * z2 - s2 * z1) * r);

            tan1[i1] += sdir;
            tan1[i2] += sdir;
            tan1[i3] += sdir;

            tan2[i1] += tdir;
            tan2[i2] += tdir;
            tan2[i3] += tdir;

            tri += 3;
        }
		
        for (int i = 0; i < (vertexCount); i++)
        {
            Vector3 n = normals[i];
            Vector3 t = tan1[i];

            // Gram-Schmidt orthogonalize
            Vector3.OrthoNormalize(ref n, ref t);

            tangents[i].x  = t.x;
            tangents[i].y  = t.y;
            tangents[i].z  = t.z;

            // Calculate handedness
            tangents[i].w = ( Vector3.Dot(Vector3.Cross(n, t), tan2[i]) < 0.0f ) ? -1.0f : 1.0f;
        }       
		
        theMesh.tangents = tangents;
    }
	
	public Cubic[] calcNaturalCubic(int n, float[] x) 
	{
		float[] gamma = new float[n+1];
		float[] delta = new float[n+1];
		float[] D = new float[n+1];
		int i;
	
		gamma[0] = 1.0f/2.0f;
		
		for ( i = 1; i < n; i++) 
		{
		  gamma[i] = 1/(4-gamma[i-1]);
		}
		
		gamma[n] = 1/(2-gamma[n-1]);
		
		delta[0] = 3*(x[1]-x[0])*gamma[0];
		
		for ( i = 1; i < n; i++) 
		{
		  delta[i] = (3*(x[i+1]-x[i-1])-delta[i-1])*gamma[i];
		}
		
		delta[n] = (3*(x[n]-x[n-1])-delta[n-1])*gamma[n];
		
		D[n] = delta[n];
		
		for ( i = n-1; i >= 0; i--) 
		{
		  D[i] = delta[i] - gamma[i]*D[i+1];
		}
		
		Cubic[] C = new Cubic[n+1];
		for ( i = 0; i < n; i++) {
		  C[i] = new Cubic((float)x[i], D[i], 3*(x[i+1] - x[i]) - 2*D[i] - D[i+1],
				   2*(x[i] - x[i+1]) + D[i] + D[i+1]);
		}
			
		return C;
	}
}

public class Cubic
{
  float a,b,c,d;        

  public Cubic(float a, float b, float c, float d){
    this.a = a;
    this.b = b;
    this.c = c;
    this.d = d;
  }
  
  public float eval(float u) 
  {
    return (((d*u) + c)*u + b)*u + a;
  }
}